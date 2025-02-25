class LinesController < ApplicationController

  before_action :set_line, only: %i[ show edit update destroy ]

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
  end

  # GET /lines/1/edit
  def edit
  end

  # POST /lines or /lines.json
  def create
    times_table_hash = eval(params[:line][:times_table]).to_h
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
    times_table_hash = eval(params[:line][:times_table]).to_h
    respond_to do |format|
      if @line.update(line_params.merge(times_table: times_table_hash))
        format.html { redirect_to lines_url, notice: "Line was successfully updated." }
        format.json { render :show, status: :ok, location: @line }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line
      @line = Line.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def line_params
      params.require(:line).permit(:name, :description, :station_list, :time_threshold, :modified_at, :priority, :html_color).tap do |whitelisted|
        whitelisted[:station_list] = whitelisted[:station_list].split(',').map(&:to_i)
      end
    end
end
