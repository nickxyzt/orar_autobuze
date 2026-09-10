# Scopul este de a obtine din informatiile din pdf-ul publicat un hash pe care sa il salvam in aplicatie
# Fisierele de input sunt "1_normal.txt", "1_weekend.txt", "1_special.txt" etc luate cu copy/paste din pdf

# ATENTIE - datele de intrare sa aiba neaparat si indexul randului (nu toate au in fisierul pdf publicat!)
### ATENTIE ### pot fi greseli in fisierul PDF - exemplu linia de autobuz 2, randul 3 - 12:04 si corect este 13:04

Dir["*.txt"].sort.each do |filename|
    info = filename.split("_")
    nr_cursa = info[0]
    rest     = info[1..-1].join("_") # restul numelui fisierului
    output_dus    = "out/#{nr_cursa}_tur_" + rest
    output_intors = "out/#{nr_cursa}_retur_" + rest
    lines = File.readlines(filename)
    lines_start  = [] # orele de start
    lines_intors = [] # orele de intors
    lines_end    = [] # orele de final
    
    # parcurgem liniile din fisier si colectam informatiile
    lines.each do |line|
      line = line.split
      lines_start  << line[1]
      lines_intors << line[2]
      lines_end    << line[3]
    end
    
    # modificam formatul, din 4:30 in "04:30"
    [lines_start, lines_intors, lines_end].each do |arr|
      arr.map! do |elem|
        h, m = elem.split /[\:\.]/ # separatorul poate fi : sau .
        h = "%02d" % h
        m = "%02d" % m
        "\"#{h}:#{m}\""
      end
    end
    
    # scriem fisierele cu orarele de dus si de intors
    # pentru liniile 3A si 3B nu exista tur-retur, asa ca scriem un singur fisier
    if ["3A", "3B"].include? nr_cursa.upcase
      out_filename = "out/#{nr_cursa}_" + rest
      File.open(out_filename, "w") do |f|
        f.write lines_start.map{|hour| "#{hour}"}.join(", ")
        f.write "\n"
        f.write lines_intors.map{|hour| "#{hour}"}.join(", ")
        f.write "\n"
        f.write lines_end.map{|hour| "#{hour}"}.join(", ")
      end
    else
      File.open(output_dus, "w") do |f|
        f.write lines_start.map{|hour| "#{hour}"}.join(", ")
        f.write "\n"
        f.write lines_intors.map{|hour| "#{hour}"}.join(", ")
      end
      File.open(output_intors, "w") do |f|
        f.write lines_intors.map{|hour| "#{hour}"}.join(", ")
        f.write "\n"
        f.write lines_end.map{|hour| "#{hour}"}.join(", ")
      end
    end
end
