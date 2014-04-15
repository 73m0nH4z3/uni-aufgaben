# encoding: utf-8

require 'mathn'
require 'csv'

class Screener
  # Setze korrekte Antworten
  def self.set_present(present)
    @@present = present
  end
  
  # Name und Antworten des Screeners
  # sind von aussen sichtbar
  attr_reader :name, :correct
  
  # Konstruktor
  def initialize(name, correct)
    @name = name                            # Name des Screeners (String)
    @correct = correct  # Antwort korrekt --> 1, inkorrekt --> 0 (Array)
  end

  def accuracy
    #############################################
    # Berechne die Accuracy für diesen Screener.
    # (diese methode ist als beispiel bereits
    # fertig implementiert. )
    #############################################
    
    num_correct = 0                         # initialisiere mit 0
    @correct.each_with_index do |correct,i| # gehe durch alle antworten
      if correct == 1                       # falls die antwort korrekt ist
        num_correct += 1                    # erhöhe anz. korrekter antworten um 1
      end
    end
    
    return num_correct / @correct.count     # teile durch anz. antworten insgesamt
    
    #############################################
  end

  def hit_rate
    # TODO ######################################
    # Berechne die Hit Rate für diesen Screener.
    
    return 0 # implement me!
        
    # END TODO ##################################
  end
  
  def miss_rate
    # TODO ######################################
    # Berechne die Miss Rate für diesen Screener.
    #############################################
    
    return 0 # implement me!
    
    # END TODO ##################################
  end

  def false_alarm_rate
    # TODO ######################################
    # Berechne die False Alarm Rate für diesen Screener.
    #############################################
    
    return 0 # implement me!
    
    # END TODO ##################################
  end
  
  def correct_rejection_rate
    # TODO ######################################
    # Berechne die Correct Rejection Rate für diesen Screener.
    #############################################
    
    return 0 # implement me!
    
    # END TODO ##################################
  end

  def sensitivity
    # TODO ######################################
    # Berechne die Sensitivity für diesen Screener.
    #############################################
    
    return 0 # implement me!
    
    # END TODO ##################################
  end

  def criterion
    # TODO ######################################
    # Berechne das Criterion für diesen Screener.
    #############################################
    
    return 0 # implement me!
    
    # END TODO ##################################
  end
  
  private
  
  # Signum-Funktion
  def sign(x)
    if x < 0
      return -1
    elsif x == 0
      return 0
    else
      return 1
    end
  end
  
  # Approximation der inversen Fehlerfunktion
  # Quelle: http://en.wikipedia.org/wiki/Error_function
  #         #Approximation_with_elementary_functions
  def erfinv(x)
    a = 0.147
    tmp = 2/(Math::PI*a) + Math.log(1-x**2)/2
    sign(x) * Math.sqrt( Math.sqrt(tmp**2 - Math.log(1-x**2)/a) - tmp )
  end
  
  # Approximation der inversen kumulierten Standardnormalverteilung
  # Quelle: http://en.wikipedia.org/wiki/Normal_
  #         distribution#Quantile_function
  def normsinv(p)
    raise ArgumentError, 'p must be between 0 and 1' unless (0..1).include? p
    Math.sqrt(2) * erfinv(2*p-1)
  end
end


class Classificator
  attr_reader :screeners
  
  def initialize(path)
    @path = path
    read_data
    create_screeners
    self
  end

  def ranking
    # TODO ######################################
    # sortiere die screener nach deinen
    # selbst gewählten kriterien, so dass
    # die besten zuvorderst in der liste stehen
    # 
    # TIP: der operator <=> gibt -1, 0 oder 1 zurück
    # und gibt an, ob ein element kleiner, genau
    # so groß oder größer ist als das andere.
    # 
    #############################################
    
    return @screeners.sort do |a,b|
      1 <=> 1 # implement me!
    end
    
    # END TODO ##################################
  end

  def top_5
    # TODO ######################################
    # hier sollen nur die besten fünf
    # screener zurückgegeben werden
    #############################################
    
    return ranking # implement me!
    
    # END TODO ##################################
  end
  
  private
  
  # Einlesen der Datensätze aus der CSV-Datei
  def read_data
    @data = CSV.read(@path)
    @head = @data.shift
    @data.each{|line| line.map! &:to_i}
    correct = @data.map{ |line| line[1] }
    Screener.set_present(correct)
  end
  
  # Erzeugen der Screener
  def create_screeners
    @screeners = []
    @head[2..-1].each_with_index do |name,i|
      correct = @data.map{ |line| line[i+2] }
      @screeners << Screener.new(name, correct)
    end
  end
end


# Output: hier muss NICHTS verändert werden!
def fmt x; x>=0 ? ("+%0.3f" % x) : ("%0.3f" % x); end
def fmtp x; "%0.2f%" % (x*100); end
cl = Classificator.new('./sdt-data.csv')
output = ""
cl.top_5.each do |screener|
  output << "#{screener.name}\n"
  output << "  A .... accuracy ................ #{fmtp screener.accuracy}\n"
  output << "  HR ... hit rate ................ #{fmtp screener.hit_rate}\n"
  output << "  MR ... miss rate ............... #{fmtp screener.miss_rate}\n"
  output << "  FAR .. false alarm rate ........ #{fmtp screener.false_alarm_rate}\n"
  output << "  CRR .. correct rejection rate .. #{fmtp screener.correct_rejection_rate}\n"
  output << "  d' ... sensitivity ............. #{fmt screener.sensitivity}\n"
  output << "  c .... criterion ............... #{fmt screener.criterion}\n"
  output << "\n"
end
puts output
# File.open('./output.txt', 'wb') do |f|
#   f << output
# end


