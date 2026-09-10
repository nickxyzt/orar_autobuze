class LinesController < ApplicationController

  before_action :set_line, only: %i[ show edit edit_schedule update update_schedule destroy ]

  # GET /lines or /lines.json
  def index
    @lines = Line.order(:priority)
  end

  # GET /lines/1 or /lines/1.json
  def show
  end

  # GET /lines/new
  def new
    @line = Line.new
    @line.modified_at = Date.today
    if Station.all.count == 1
      # Daca avem o singura statie
      @line.station_list = [Station.first.id, Station.first.id]
    elsif Station.all.count >= 2
      # Luam 2 statii la intamplare
      @line.station_list = [Station.first.id, Station.last.id]
    else
      # Aici ar trebui ceva pentru cazul cand nu avem statii in lista...
    end
  end

  # GET /lines/1/edit
  def edit
  end

  # GET /lines/1/edit_schedule
  def edit_schedule
  end

  # POST /lines or /lines.json
  def create
    times_table_hash = {"working" => [[1,2,3,4,5], []], "holiday" => [[0,6], []]} # un orar valid dar foarte simplu
    @line = Line.new(line_params.merge(times_table: times_table_hash))

    respond_to do |format|
      if @line.save
        format.html { redirect_to lines_url, notice: "Line was successfully created." }
        format.json { render :show, status: :created, location: @line }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lines/1 or /lines/1.json
  def update
    respond_to do |format|
      if @line.update(line_params)
        format.html { redirect_to lines_url, notice: "Line was successfully updated." }
        format.json { render :show, status: :ok, location: @line }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lines/1/update_schedule
  def update_schedule
    respond_to do |format|
      # construire manuala a orarului
      times_table = {}
      ["working", "holiday"].each do |day_kind|
        times_table[day_kind] = [[],{}]
        (0..6).each do |day_index|
          if params["ck_#{day_kind}_#{day_index}"]
            times_table[day_kind][0] << day_index
          end
        end
      end
      # pentru holiday_special nu bifam zilele saptamanii
      times_table["holiday_special"] = [nil, {}]

      # adaugam momentele si timpii
      # convertim intai params in array de array
      schedule_working = JSON.parse(params["schedule_working"])
      schedule_holiday = JSON.parse(params["schedule_holiday"])
      schedule_holiday_special = JSON.parse(params["schedule_holiday_special"])

      # informatiile primite sunt in format de tipul:
      # [[0, ["07:15", "08:15", "09:15"]], [15, ["08:00", "09:00", "10:00"]]]
      schedule_working.each do |row|
        times_table["working"][1][row[0]] = row[1]
      end
      schedule_holiday.each do |row|
        times_table["holiday"][1][row[0]] = row[1]
      end
      schedule_holiday_special.each do |row|
        times_table["holiday_special"][1][row[0]] = row[1]
      end

      logger.info times_table
      logger.info "a"*100
      @line.times_table = times_table
      if @line.save
        format.html { redirect_to @line, notice: "Line schedule was successfully updated." }
      end
    end
  end

  # DELETE /lines/1 or /lines/1.json
  def destroy
    @line.destroy

    respond_to do |format|
      format.html { redirect_to lines_path, status: :see_other, notice: "Line was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Verificare program (schedules)
  def check_all_schedules
    @results = [] # Aici colectam timpii gresiti
    Line.all.each do |line|
      # Obtinem un Hash de tipul {0 => ["04:30", "05:00"], 6 => ["05:00", "06:00"]}, 15 => ["05:30", "06:30"]}
      schedule = line[:times_table]["working"][1]

      keys   = schedule.keys   # statiile "cheie"
      values = schedule.values # timpii de sosire in statiile "cheie"

      # Parcurgem valorile pentru fiecare timp de plecare si vedem daca sunt ordonate alfanumeric
      values.first.count.times do |index|
        this_time_values = []
        keys.each do |key|
          this_time_values << schedule[key][index]
        end
        if this_time_values != this_time_values.sort
          @results << "Linia #{line.name} are gresit timpii #{this_time_values}"
        end
      end

    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line
      @line = Line.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def line_params
      params.require(:line).permit(:name, :description, :priority, :html_color, :station_list, :info, :modified_at, :time_threshold, :schedule_weblink).tap do |whitelisted|
        whitelisted[:station_list] = whitelisted[:station_list].split(',').map(&:to_i)
      end
    end
end
