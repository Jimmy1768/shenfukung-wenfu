# frozen_string_literal: true

module Seeds
  module TempleDemoUsers
    extend self

    USERS = [
      {
        email: Seeds::AuthCore::PRIMARY_EMAIL,
        english_name: "Wen-te Chen",
        native_name: "陳文德",
        national_id: "A123456789",
        birthdate: Date.parse("1982-04-18"),
        phone: "0912-345-678",
        notes: "希望安排上午時段，因長輩午休。",
        temple_profile: {
          household_reference: "鹿港陳氏宗親會",
          preferred_language: "zh-TW",
          preferred_branch: "本殿",
          zodiac: "Dog"
        },
        offerings: {
          "lantern-lighting" => {
            preferred_slot: "Evening",
            dedication_message: "祈求全家平安順遂",
            quantity: 2
          },
          "ancestor-ritual" => {
            ancestor_placard_name: "陳府歷代祖先",
            incense_option: "Five-stick set",
            logistics: "需要扶梯協助"
          }
        },
        household_members: ["陳美齡", "陳昊儒"],
        dependents: [
          { english_name: "Chen Mei-ling", native_name: "陳美齡", relationship_label: "Spouse" },
          { english_name: "Chen Hao-ru", native_name: "陳昊儒", relationship_label: "Son" }
        ]
      },
      {
        email: Seeds::AuthCore::SECONDARY_EMAIL,
        english_name: "Hsin-yu Lin",
        native_name: "林心宇",
        birthdate: Date.parse("1990-11-02"),
        phone: "0987-654-321",
        notes: "照顧祖母行動，偏好下午到場。",
        temple_profile: {
          household_reference: "林府安居堂",
          preferred_language: "zh-TW",
          preferred_branch: "天官殿",
          zodiac: "Horse"
        },
        offerings: {
          "pudu-table" => {
            preferred_date: "中元普渡",
            logistics: "需要靠近出入口的桌位",
            dedication_message: "為林家祈福"
          }
        },
        household_members: ["林桂英"],
        dependents: [
          { english_name: "Lin Gui-ying", native_name: "林桂英", relationship_label: "Grandmother" }
        ]
      },
      {
        email: Seeds::AuthCore::STAFF_ADMIN_EMAIL,
        english_name: "Admin Ling",
        native_name: "林管理",
        birthdate: Date.parse("1988-08-08"),
        phone: "0933-888-888",
        notes: "想要先以信眾身份測試系統。",
        temple_profile: {
          household_reference: "林府管理戶",
          preferred_language: "zh-TW",
          preferred_branch: "本殿",
          zodiac: "Dragon"
        },
        offerings: {
          "lantern-lighting" => {
            dedication_message: "為信眾示範報名流程",
            quantity: 1
          }
        },
        household_members: ["林依婷"],
        dependents: [
          { english_name: "Lin Yi-ting", native_name: "林依婷", relationship_label: "Sister" }
        ]
      },
      {
        email: Seeds::AuthCore::PATRON_EMAIL,
        english_name: "Patron Kao",
        native_name: "高信眾",
        birthdate: Date.parse("1975-05-17"),
        phone: "0911-555-777",
        notes: "將用來測試家屬與報名流程。",
        temple_profile: {
          household_reference: "高家團圓",
          preferred_language: "zh-TW",
          preferred_branch: "天官殿",
          zodiac: "Rabbit"
        },
        offerings: {
          "ancestor-ritual" => {
            ancestor_placard_name: "高府祖先",
            dedication_message: "家族平安",
            incense_option: "Three-stick set"
          }
        },
        household_members: ["高雅琪", "高雅蘭"],
        dependents: [
          { english_name: "Kao Ya-chi", native_name: "高雅琪", relationship_label: "Mother" },
          { english_name: "Kao Ya-lan", native_name: "高雅蘭", relationship_label: "Aunt" }
        ]
      }
    ].freeze

    def seed
      puts "Seeding temple demo users..." # rubocop:disable Rails/Output
      USERS.each { |config| apply_profile(config) }
      ensure_dev_client_account!
      connect_demo_patrons!
    end

    # The Expo dev-client prefills these credentials so the Director never has
    # to type on a phone (mobile/App.js: 'member@example.test' /
    # 'templemate-demo', matching app/dummy/fixtures.js). In dummy mode they
    # resolve against local fixtures; in real mode against Rails, where the
    # account simply did not exist -- so the prefill was dead the moment the
    # client pointed at a real API.
    #
    # Development and test only: this is a known weak password and must never
    # reach a real environment.
    DEV_CLIENT_EMAIL = "member@example.test"
    DEV_CLIENT_PASSWORD = "templemate-demo"

    def ensure_dev_client_account!
      return unless Rails.env.development? || Rails.env.test?

      user = User.find_or_initialize_by(email: DEV_CLIENT_EMAIL)
      user.assign_attributes(
        english_name: "Lin Xiao An",
        native_name: "林小安", # mirrors the dummy fixture identity
        encrypted_password: User.password_hash(DEV_CLIENT_PASSWORD)
      )
      user.save! if user.changed?
      puts "Dev-client account ready (#{DEV_CLIENT_EMAIL})." # rubocop:disable Rails/Output
      user
    end

    # Binding is the join (see TempleConnection), so seeded patrons need a
    # connection or every temple's admin patron list comes up empty after
    # bin/reset_backend. This stands in for the QR scan they would do on a
    # real device.
    def connect_demo_patrons!
      emails = USERS.map { |config| config[:email] }
      emails << DEV_CLIENT_EMAIL if Rails.env.development? || Rails.env.test?
      users = User.where(email: emails)
      Temple.find_each do |temple|
        users.each { |user| TempleConnection.record!(user:, temple:) }
      end
      puts "Connected #{users.count} demo patrons to #{Temple.count} temples." # rubocop:disable Rails/Output
    end

    private

    def apply_profile(config)
      user = User.find_by(email: config[:email])
      return unless user

      user.assign_attributes(
        english_name: config[:english_name] || user.english_name,
        native_name: config[:native_name] || user.native_name,
        national_id: config[:national_id] || user.national_id,
        birthdate: config[:birthdate] || user.birthdate,
        metadata: merged_metadata(user.metadata, config)
      )
      user.save! if user.changed?

      ensure_dependents(user, config[:dependents])
    end

    def merged_metadata(existing, config)
      (existing || {}).deep_merge(
        "phone" => config[:phone],
        "notes" => config[:notes],
        "household_members" => config[:household_members],
        "temple_profile" => config[:temple_profile],
        "offerings" => config[:offerings],
        "seeded_by" => "db:seed:temple_demo_users"
      ).compact
    end

    def ensure_dependents(user, dependents)
      Array(dependents).each do |attrs|
        dependent = Dependent.find_or_create_by!(english_name: attrs[:english_name]) do |dep|
          dep.native_name = attrs[:native_name]
          dep.relationship_label = attrs[:relationship_label]
          dep.metadata = (dep.metadata || {}).merge(seed_metadata)
        end

        UserDependent.find_or_create_by!(user:, dependent: dependent).tap do |link|
          link.role ||= "family"
          link.metadata = (link.metadata || {}).merge(seed_metadata)
          link.save! if link.changed?
        end
      end
    end

    def seed_metadata
      { seeded_by: "db:seed:temple_demo_users" }
    end
  end
end
