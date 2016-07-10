#include <stdio.h>
#include <sys/select.h>
#include <unistd.h>
#include <sys/resource.h>
/*

  turns the output of `hcidump --raw` into a hex stream
  compile and install:
  $ gcc -o otraw2q -O3 -Wall otraw2q.c && sudo install -s -m 755 -o root -g root otraw2q /usr/local/bin/

  example usage:
  $ sudo hcidump -i $hcidevice --raw | otraw2q | mosquitto_pub -t "/opentrigger/rawhex/$hcimac" -l

  this could also be done with `tr` but would leave one message lingering and is a litte bit slower
  $ sudo hcidump -i $hcidevice --raw | stdbuf -i0 -o0 tr -d '\n ' | stdbuf -i0 -o0 tr '>' '\n' | mosquitto_pub -t "/opentrigger/rawhex/$hcimac" -l

  Possible improvements:
  - publish with MQTTPacket
  - turn hex stream into binary stream

*/

int set_priority(int priority){
  int which = PRIO_PROCESS;
  id_t pid;

  pid = getpid();
  return setpriority(which, pid, priority);
}


int main(void)
{
  set_priority(10);
  fd_set set;
  struct timeval timeout;

  int rv;
  char buff[2];
  int len = 1;
  size_t read_len, write_len;
  int last_n = 1;
  int logo_text = 1;
  int timeoutcount = 0;

  while(1){

    FD_ZERO(&set);
    FD_SET(STDIN_FILENO, &set);
    timeout.tv_sec = 0;
    timeout.tv_usec = 10000; // 10msec

    if(timeoutcount > 5){
      // go easy on resources if there is nothing to do
      timeout.tv_usec = 150000; //150msec
      timeoutcount=0;
    }

    // wait for input
    rv = select(STDIN_FILENO + 1, &set, NULL, NULL, &timeout);

    if(rv == -1){

      // error
      return 1;

    } else if(rv == 0) {

      // timeout
      timeoutcount++;
      if(last_n) continue;
      printf("\n");
      fflush(stdout);
      last_n = 1;

    } else {

      // we have some data
      read_len = read( STDIN_FILENO, buff, len );
      if(read_len > 0){
        if (buff[0] == ' ' || buff[0] == '\n') continue;
        if (buff[0] == '>') {
          if(!last_n) {
            printf("\n");
            fflush(stdout);
          }
          logo_text = 0;
          last_n = 1;
          continue;
        }
        if(!logo_text) {
          write_len = write ( STDOUT_FILENO, buff, read_len );
          if(write_len != read_len) return 2; // error
          fflush(stdout);
          last_n = 0;
        }
      }
    }
  }
}
