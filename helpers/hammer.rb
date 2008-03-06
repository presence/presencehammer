require 'thread'

#A class to execute dial strategies for inbound testing loads on Asterisk/OpenGate
class Hammer
  
  def self.launch_call(phone_number, profile, instructions)

    #Finish setting our instructions into a variable to be attached to the channel we create
    if $HELPER[:hammer][:profile][:before_delay] != nil
      instructions = instructions + ",before_delay=" + $HELPER[:hammer][:profile][:before_delay].to_s
    else
      instructions = instructions + ",before_delay=0"
    end
    if $HELPER[:hammer][:profile][:after_delay] != nil
      instructions = instructions + ",after_delay=" + $HELPER[:hammer][:profile][:after_delay].to_s
    else
      instructions = instructions + ",after_delay=0"
    end
    if $HELPER[:hammer][:profile][:message] != nil
      instructions = instructions + ",message=" + $HELPER[:hammer][:profile][:message].to_s
    else
      instructions = instructions + ",message=nil"
    end
    
    #Determine if the channel type is IAX2 or SIP and make a determination on how to dial
    channel_type = $HELPERS[:hammer][:profile][:channel].split('/')
    if channel_type == "IAX2"
      channel = $HELPERS[:hammer][:profile][:channel] + phone_number
    else
      channel = $HELPERS[:hammer][:profile][:channel] + phone_number
    end
    
    response = PBX.rami_client.originate({:channel => channel,
                                          :context =>  $HELPERS[:hammer][:profile][:context],
                                          :exten =>  $HELPERS[:hammer][:profile][:extension],
                                          :priority => $HELPERS[:hammer][:profile][:priority],
                                          :callerid => $HELPERS[:hammer][:profile][:callerid],
                                          :timeout => $HELPERS[:hammer][:profile][:timeout],
                                          :variable => instructions,
					                                :async => $HELPERS[:hammer][:profile][:async]})
    return response
  end
  
  def execute_strategy
    $HELPERS[:hammer][:dial_strategy].each do |strategy|

      #Set our instructions to include in the variable for the AGI
      instructions = String.new
      if strategy.dtmf != nil
        instructions = "send_dtmf=" + strategy.send_dtmf.to_s
      else
        instructions = "send_dtmf=nil"
      end
      if strategy.call_length != nil
        instructions = instructions + ",call_length=" + strategy.call_length.to_s
      else
        instructions = instructions + ",call_length=0"
      end

      #Luanch the individual calls
      response = self.launch_call strategy.number, strategy.profile, instructions
    end
  end

  #Our main thread so that we launch the MAPI Hammer while the rest of Adhearsion executes  
  Thread.new do

    #Number of seconds for the loop to start ensuring we have a connection to the ManagerAPI
    sleep $HELPERS[:hammer][:sleep_before_start]
    
    #Execute an endless loop until Adhearsion is shut down
    loop do
      
      #Execute the strategy the number of times requested before pausing
      cnt = 0
      while cnt < $HELPERS[:hammer][:cycle_length] do
        #If threading is set to true, each strategy will be executed in its own thread for simultaneous calling
        #if not, simply execute one at a time
        if $HELPERS[:hammer][:thread_cycles] == true
          Thread.new do
            execute_strategy
          end
        else
          execute_strategy
        end
      end
      #Sleep the time requested between launching a strategy
      sleep $HELPERS[:hammer][:delay_between_cycle]
    end
  end
  
end