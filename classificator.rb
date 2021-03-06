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
    num_hits = 0                         
    @correct.each_with_index do |correct,i|
      if correct == 1 && @@present[i] == 1                   
	num_hits += 1                 
      end
    end
    
    return num_hits / @correct.count 
        
  end
  
  def miss_rate
     num_miss = 0                         
    @correct.each_with_index do |correct,i|
      if correct == 0 && @@present[i] == 1                   
		num_miss += 1                 
      end
    end
    
    return num_miss / @correct.count 
        
  end

 

  def false_alarm_rate
     num_false_alarm = 0                         
    @correct.each_with_index do |correct,i|
      if correct == 0 && @@present[i] == 0                   
		num_false_alarm += 1                 
      end
    end
    
    return num_false_alarm / @correct.count 
        
  end
  
  def correct_rejection_rate
     num_correct_rejection = 0                         
    @correct.each_with_index do |correct,i|
      if correct == 1 && @@present[i] == 0                   
		num_correct_rejection += 1                 
      end
    end
    
    return num_correct_rejection / @correct.count 
        
  end

  def sensitivity
    return normsinv(hit_rate) - normsinv(false_alarm_rate) 
  end

  def criterion
    return (-0.5*(normsinv(false_alarm_rate) + normsinv(hit_rate))) 
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
    self end
  
    def average
	avg_hit_rate = 0
	avg_miss_rate = 0
	avg_false_alarm_rate = 0
	avg_correct_rejection_rate = 0
	@screeners.each do | screener |
		avg_hit_rate += screener.hit_rate
		avg_miss_rate += screener.miss_rate
		avg_false_alarm_rate += screener.false_alarm_rate
		avg_correct_rejection_rate += screener.correct_rejection_rate
	end

	avg_hit_rate /= @screeners.count
	avg_miss_rate  /= @screeners.count
	avg_false_alarm_rate  /= @screeners.count
	avg_correct_rejection_rate  /= @screeners.count

	return [avg_hit_rate, avg_miss_rate, avg_false_alarm_rate, avg_correct_rejection_rate]
  end
  

  def ranking
    # sortiere die screener nach deinen
    # selbst gewählten kriterien, so dass
    # die besten zuvorderst in der liste stehen
    # 
    # TIP: der operator <=> gibt -1, 0 oder 1 zurück
    # und gibt an, ob ein element kleiner, genau
    # so groß oder größer ist als das andere.
    
    return @screeners.sort do |a,b|
      if get_argument("-s") == "a"
        b.accuracy <=> a.accuracy
      elsif get_argument("-s") == "h"
        b.hit_rate <=> a.hit_rate
	  elsif get_argument("-s") == "f"
        b.false_alarm_rate <=> a.false_alarm_rate
      else
        b.sensitivity <=> a.sensitivity
      end
    
 
    end
    
  end

  def top_5
    # hier sollen nur die besten fünf
    # screener zurückgegeben werden
    
    if get_argument("-e")
      return ranking
    else
      return ranking[0..4]
    end
    
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

def get_argument(flag)
  ARGV.each_with_index do |argument,i|
    if argument == flag 
      return ARGV[i+1]
    end
  end 
  return false
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

# Wir machen's aber TROTZDEM
if get_argument("-a")
  output_average = "Average:\n"
  output_average << "  HR ... hit rate ................ #{fmtp cl.average[0]}\n"
  output_average << "  MR ... miss rate ............... #{fmtp cl.average[1]}\n"
  output_average << "  FAR .. false alarm rate ........ #{fmtp cl.average[2]}\n"
  output_average << "  CRR .. correct rejection rate .. #{fmtp cl.average[3]}\n"
  output_average << "\n"
  output << output_average
end
 
puts output

# File.open('./output.txt', 'wb') do |f|
#   f << output
# end

