# This is an example dialplan. Feel free to remove this file and
# start your dialplan from scratch.


# This "internal" context would map over if Adhearsion were invoked
# in Asterisk's own "internal" context. For example, if you set up
# your extensions.conf file for Adhearsion as so:
#
# [internal]
#     exten => _.,1,AGI(agi://192.168.1.3)
#
# then, when Adhearsion receives that call, it sees it came from
# the "internal" context and invokes this.
presence_hammer {
  #Context used to treat calls generated by the Hammer Class
  
  #First we collect the variables from the Asterisk channel with instructions on what to do with this calls
  send_dtmf = get_variable "send_dtmf"
  call_length = get_variable "call_length"
  before_delay = get_variable "before_delay"
  after_delay = get_variable "after_delay"
  message = get_variable "message"
  
  #Now, lets treat the call
  sleep before_delay.to_i
  if send_dtmf != nil
    dtmf send_dtmf
    sleep after_delay.to_i
  end
  if message != nil
    play message
  end
  sleep call_length.to_i
}