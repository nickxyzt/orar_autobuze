class StopsController < ApplicationController
  before_action :set_stop, only: %i[ show edit update destroy ]

  def index
    @stops = Stop.order('created_at DESC').limit(50)
  end

  def show
  end

  def new
    @stop = Stop.new
  end

  def edit
  end

  def create
    @stop = Stop.new(stop_params)

    respond_to do |format|
      if @stop.save
        format.html { redirect_to stops_url, notice: "Stop was successfully created.|success" }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stop.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @stop.update(stop_params)
        format.html { redirect_to stops_url, notice: "Stop was successfully updated.|success" }
        format.json { render :show, status: :ok, location: @stop }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stop.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @stop.destroy

    respond_to do |format|
      format.html { redirect_to stops_path, status: :see_other, notice: "Stop was successfully destroyed.|success" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stop
      @stop = Stop.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stop_params
      params.require(:stop).permit(:line_id, :station_id, :created_at)
    end
end
