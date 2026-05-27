class User < ApplicationRecord
    has_secure_password

    validates :email, uniqueness: true, allow_blank: false
    validates :matricula, uniqueness: true, allow_blank: false
    validates :password, length: { minimum: 6 }
    validates :role, inclusion: { in: %w[admin discente docente] }

    def self.find_by_login(login)
        find_by(email: login) || find_by(matricula: login)
    end

    def admin?
        role == "admin"
    end
end
