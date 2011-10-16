#!/usr/bin/env ruby
require 'colored'

module Status
  def ohai(msg)
    puts msg.white
  end
  def opoo(msg)
    puts msg.red
  end
  def oyay(msg)
    puts msg.green
  end
  def canduz(msg)
    puts "\t--- #{msg}"
  end
  def didit(msg, notrly = Choice[:dryrun])
    if notrly
      puts "\t*** #{msg}".yellow + " *".white.bold
    else
      puts "\t*** #{msg}".yellow
    end
  end
  
  def izdun
    puts "\t\t...done!".white.bold
  end

  def item_status( test_function, desc )
    if test_function
      oyay("...is #{desc}.")
    else
      opoo("...is not #{desc}.")
    end
    return test_function
  end
end