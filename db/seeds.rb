# frozen_string_literal: true

# Optimize seeds with batch inserts and better performance
puts "Starting database seeding..."

# Create users in batches
puts "Creating users..."
User.transaction do
  users = []
  20.times do
    users << {
      email: Faker::Internet.unique.email,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      country_code: Faker::Address.country_code
    }
  end
  User.insert_all(users)
end

# Create trading accounts in batches
puts "Creating trading accounts..."
User.transaction do
  trading_accounts = []
  User.all.each do |user|
    rand(1..5).times do
      trading_accounts << {
        user_id: user.id,
        name: "#{user.first_name}'s Account #{Faker::Number.number(digits: 3)}",
        login: Faker::Number.unique.number(digits: 10).to_s,
        phase: TradingAccount.phases.keys.sample,
        platform: TradingAccount.platforms.keys.sample
      }
    end
  end
  TradingAccount.insert_all(trading_accounts)
end

# Create IP addresses in batches
puts "Creating IP addresses..."
IpAddress.transaction do
  ip_addresses = []
  100.times do
    ip_addresses << {
      address: Faker::Internet.unique.ip_v4_address,
      region: Faker::Address.state,
      country: Faker::Address.country_code,
      city: Faker::Address.city,
      lat: Faker::Address.latitude,
      lon: Faker::Address.longitude,
      is_vpn: [true, false].sample
    }
  end
  IpAddress.insert_all(ip_addresses)
end

# Create IP activities with realistic distribution
puts "Creating IP activities..."
User.transaction do
  ip_activities = []
  
  # Pre-load all users, trading accounts, and IP addresses
  users = User.includes(:trading_accounts).all
  ip_addresses = IpAddress.all.to_a
  
  users.each_with_index do |user, user_index|
    puts "Processing user #{user.id} (#{user_index + 1}/#{users.size})..."
    
    # Create KYC activities
    kyc_count = rand(1..10)
    kyc_count.times do
      ip_activities << {
        user_id: user.id,
        trading_account_login: nil,
        ip_address: ip_addresses.sample.address,
        activity_type: 'kyc',
        created_at: rand(6.months.ago..Time.current)
      }
    end
    
    # Create LOGIN activities
    login_count = rand(10..100)
    login_count.times do
      ip_activities << {
        user_id: user.id,
        trading_account_login: nil,
        ip_address: ip_addresses.sample.address,
        activity_type: 'login',
        created_at: rand(3.months.ago..Time.current)
      }
    end
    
    # Create TRADE activities
    user.trading_accounts.each do |trading_account|
      trade_count = rand(50..500)
      trade_count.times do
        ip_activities << {
          user_id: user.id,
          trading_account_login: trading_account.login,
          ip_address: ip_addresses.sample.address,
          activity_type: 'trade',
          created_at: rand(1.month.ago..Time.current)
        }
      end
    end
    
    # Insert activities in batches of 1000
    if ip_activities.size >= 1000
      IpActivity.insert_all(ip_activities)
      ip_activities.clear
    end
  end
  
  # Insert remaining activities
  IpActivity.insert_all(ip_activities) unless ip_activities.empty?
end

# Create additional high-volume data for performance testing
puts "Creating additional high-volume data for performance testing..."
User.transaction do
  sample_users = User.limit(5).includes(:trading_accounts).to_a
  
  sample_users.each do |user|
    user.trading_accounts.each do |trading_account|
      additional_trades = rand(1000..2000)
      puts "Adding #{additional_trades} additional trade activities for trading account #{trading_account.login}..."
      
      ip_activities = []
      ip_addresses = IpAddress.all.to_a
      
      additional_trades.times do |i|
        ip_activities << {
          user_id: user.id,
          trading_account_login: trading_account.login,
          ip_address: ip_addresses.sample.address,
          activity_type: 'trade',
          created_at: rand(6.months.ago..Time.current)
        }
        
        # Insert in batches of 1000
        if (i + 1) % 1000 == 0
          IpActivity.insert_all(ip_activities)
          ip_activities.clear
          puts "Progress: #{i + 1}/#{additional_trades}"
        end
      end
      
      # Insert remaining activities
      IpActivity.insert_all(ip_activities) unless ip_activities.empty?
    end
  end
end

puts "Seed data created successfully!"
puts "Summary:"
puts "- Users: #{User.count}"
puts "- Trading Accounts: #{TradingAccount.count}"
puts "- IP Addresses: #{IpAddress.count}"
puts "- IP Activities: #{IpActivity.count}"
puts "  - KYC: #{IpActivity.kyc.count}"
puts "  - Login: #{IpActivity.login.count}"
puts "  - Trade: #{IpActivity.trade.count}"
