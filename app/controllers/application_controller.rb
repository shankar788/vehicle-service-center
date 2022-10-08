# frozen_string_literal: true

class ApplicationController < ActionController::Base
    rescue_from CanCan::AccessDenied do
        redirect_to root_path
    end
end
