class SpecialDaysController < ApplicationController
  before_action :set_special_day, only: %i[ show edit update destroy ]

  # GET /special_days or /special_days.json
  def index
    @special_days = SpecialDay.order('day DESC')
  end

  # GET /special_days/1 or /special_days/1.json
  def show
  end

  # GET /special_days/new
  def new
    @special_day = SpecialDay.new
  end

  # GET /special_days/1/edit
  def edit
  end

  # POST /special_days or /special_days.json
  def create
    @special_day = SpecialDay.new(special_day_params)

    respond_to do |format|
      if @special_day.save
        format.html { redirect_to @special_day, notice: "Special day was successfully created." }
        format.json { render :show, status: :created, location: @special_day }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @special_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /special_days/1 or /special_days/1.json
  def update
    respond_to do |format|
      if @special_day.update(special_day_params)
        format.html { redirect_to special_days_url, notice: "Special day was successfully updated." }
        format.json { render :show, status: :ok, location: @special_day }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @special_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /special_days/1 or /special_days/1.json
  def destroy
    @special_day.destroy

    respond_to do |format|
      format.html { redirect_to special_days_path, status: :see_other, notice: "Special day was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_special_day
      @special_day = SpecialDay.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def special_day_params
      params.require(:special_day).permit(:day, :kind_id)
    end
end
