class User < ApplicationRecord
    has_secure_password

    validates :email, uniqueness: true
    validates :password, length: { minimum: 6 }
    validates :role, inclusion: { in: %w[admin discente docente] }
    validates :matricula, uniqueness: true

    def self.find_by_login(login)
        find_by(email: login) || find_by(matricula: login)
    end
end
