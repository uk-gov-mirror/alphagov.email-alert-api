class MessagePresenter < ApplicationPresenter
  def initialize(message, frequency: "immediate")
    @message = message
    @frequency = frequency
  end

  def call
    message.body
  end

private

  attr_reader :message
end
