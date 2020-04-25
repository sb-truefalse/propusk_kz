class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|
      t.bigint :tg_chat_id
      t.integer :tg_type
      t.json :data

      t.timestamps
    end
  end
end
