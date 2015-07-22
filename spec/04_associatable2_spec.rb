require '04_associatable2'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :cats, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLObject
      has_many :humans

      finalize!
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      cat_assoc_options = Cat.assoc_options
      human_options = cat_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Cat.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Cat.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Cat
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:cat) { Cat.find(1) }

    it 'adds getter method' do
      expect(cat).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Cat`' do
      house = cat.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('26th and Guerrero')
    end
  end

  describe '#has_many_through' do
    before(:all) do
      class Doctor < SQLObject
        has_many :appointments
        has_many :stethoscopes
        finalize!
      end

      class Appointment < SQLObject
        belongs_to :doctor
        belongs_to :patient
        has_many_through :stethoscopes, :doctor, :stethoscopes
        finalize!
      end

      class Patient < SQLObject
        has_many :appointments
        has_many_through :doctors, :appointments, :doctor
        finalize!
      end

      class Stethoscope < SQLObject
        belongs_to :doctor
        finalize!
      end
    end

    let(:patient) { Patient.find(1) }
    let(:appt) { Appointment.find(1) }

    it "finds many doctors for a patient through appointments (has_many => belongs_to)" do
      doctors = patient.doctors

      expect(doctors.first).to be_instance_of(Doctor)
      expect(doctors.length).to eq(3)
    end

    it "finds many stethoscopes for an appointment through doctor (belongs_to => has_many)" do
      stethoscopes = appt.stethoscopes

      expect(stethoscopes.first).to be_instance_of(Stethoscope)
      expect(stethoscopes.length).to eq(2)
    end
  end
end
