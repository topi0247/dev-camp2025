namespace :db do
  desc "1000万件のランダムユーザーデータを作成"
  task create_bulk_users: :environment do
    require 'faker'

    total_records = 10_000_000
    batch_size = 10_000
    total_batches = (total_records / batch_size.to_f).ceil

    puts "#{total_records}件のユーザーデータを作成開始..."
    start_time = Time.current

    total_batches.times do |batch_num|
      users = []

      batch_size.times do |i|
        # 日本人の氏名をランダム生成
        users << {
          last_name: Faker::Name.last_name,
          first_name: Faker::Name.first_name,
          email: Faker::Internet.unique.email,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      # バルクインサートで高速化
      User.insert_all(users)

      # 進捗表示
      completed = (batch_num + 1) * batch_size
      progress = ((completed / total_records.to_f) * 100).round(2)
      elapsed = Time.current - start_time
      eta = (elapsed / completed) * (total_records - completed)

      puts "[#{progress}%] #{completed}/#{total_records}件完了 (経過: #{elapsed.to_i}秒, 残り: #{eta.to_i}秒)"

      # メモリリークを防ぐ
      GC.start if batch_num % 10 == 0
    end

    total_time = Time.current - start_time
    puts "\n完了! 総時間: #{total_time.to_i}秒 (#{(total_time / 60).round(2)}分)"
  end
end