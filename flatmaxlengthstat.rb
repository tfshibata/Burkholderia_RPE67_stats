#!/bin/env ruby
require 'bio'

class PBreadlengths
  def initialize(str = nil)
    @read_name = str
    @lengths = Array.new
  end
  def add_subread(length)
    @lengths << length
  end
  def sameread(readname)
    return readname == @read_name
  end
  def print
    str = "#{@read_name}\t#{@lengths.max}\t#{@lengths.join(' ')}" 
    puts str unless str == "\t\t"
  end
  attr_accessor :lengths
  attr_reader :read_name
end

class PBiterator
  def initialize(ff)
    @ff=ff
    @lastread = PBreadlengths.new
  end
  def each
    while fe = @ff.next_entry
      ary=fe.entry_id.split("/")
      readname = "#{ary[0]}/#{ary[1]}"
      if @lastread.sameread(readname)
        @lastread.add_subread(fe.seq.length)
      else
        yield @lastread
        @lastread = PBreadlengths.new(readname)
        @lastread.add_subread(fe.seq.length)
      end
    end
    yield @lastread
  end
end
qname=ARGV[0]
jobid=""
samplename=""
xmlname=File.dirname(qname)+"/../input.xml"
xmlfile=File.open(xmlname)
xmlfile.each_line do |line|
  if line =~ /<jobId>(.*)<\/jobId>/
    jobid=$1
  end
  if line =~ /<sampleName>(.*)<\/sampleName>/
    samplename=$1
  end
end
ff=nil
begin
  ff = Bio::FlatFile.new(nil, ARGF)
rescue
  ff = Bio::FlatFile.new(Bio::Fastq, ARGF)
end
pbi = PBiterator.new(ff)
maxlengths = Array.new
pbi.each do |pb|
#  pb.print
  maxlengths << pb.lengths.max
end
sum = 0
c = 0
maxlengths.each do |l|
#  puts l
  if l != nil
    sum += l
    c += 1
  end
end
puts "#{jobid}\t#{samplename}\t#{sum}\t#{sum/c}\t#{c}\n"
