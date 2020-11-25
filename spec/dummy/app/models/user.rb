# frozen_string_literal: true

class User < ApplicationRecord
  has_many :friends, class_name: 'User'
  has_many :parents, class_name: 'User'
end
