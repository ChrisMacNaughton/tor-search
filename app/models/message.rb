class Message < ActiveRecord::Base

  acts_as_textcaptcha bcrypt_salt: "$2a$10$8VWDl/.y0ei0sfU7KfKksO",
                      bcrypt_cost: 5,
                      questions: [
                        {'question' => 'two + 12', 'answers' => '14,fourteen'},
                        {'question' => 'Is a purple box green?', 'answers' => 'no'},
                        {'question' => 'If tomorrow is Saturday, what day is today?', 'answers'=>'friday,today'},
                        {'question' => 'If a duck is black, what kind of bird is it?', 'answers' => 'duck,a duck'},
                        {'question' => 'If a duck is black, what color is it?', 'answers' => 'black'},
                        {'question' => 'What color is the black house?', 'answers' => 'black'}
                      ]

  attr_accessible :advertising, :contact_method, :name, :text, :spam_answer
end
