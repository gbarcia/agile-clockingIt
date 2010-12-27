# To change this template, choose Tools | Templates
# and open the template in the editor.

module Statistics
  def self.mean(array)
    result = array.inject(0) {|sum, x| sum +=x } /array.size.to_f
    return result.ceil
  end

  def self.standard_desviation(array)
    m = mean(array)
    variance = array.inject(0) {|variance,x| variance += (x-m) ** 2}
    result = Math.sqrt(variance/(array.size - 1))
    return (result * 10**2).round.to_f / 10**2 #round two decimals
  end

  def self.greather_num (array)
    greather = array[0]
    array.each do |item|
      if greather < item
        greather = item
      end
    end
    return greather
  end
end
