require 'libnotify'
require 'date'

class Task
  attr_accessor :description, :priority, :completed, :due_date, :due_time

  def initialize(description, priority, due_date, due_time)
    @description = description
    @priority = priority
    @completed = false
    @due_date = due_date
    @due_time = due_time
  end

  def mark_as_completed
    @completed = true
  end
end

class TaskList
  def initialize
    @tasks = []
  end

  def current_date_time
    Time.now
  end

  def add_task(description, priority, due_day, due_month, due_hour, due_minute)
    current_time = current_date_time
    due_date = Date.new(current_time.year, due_month.to_i, due_day.to_i)
    due_time = Time.new(current_time.year, current_time.month, current_time.day, due_hour.to_i, due_minute.to_i)
    task = Task.new(description, priority, due_date, due_time)
    @tasks << task
    puts "Tarefa adicionada: #{description} (Prioridade: #{priority})"
  end

  def list_tasks
    puts "Lista de Tarefas:"
    @tasks.each_with_index do |task, index|
      status = task.completed ? "[X]" : "[ ]"
      puts "#{index + 1}. #{status} #{task.description} (Prioridade: #{task.priority}) - Data de Vencimento: #{task.due_date} Hora de Vencimento: #{task.due_time.strftime('%H:%M')}"
    end
  end

  def mark_task_as_completed(task_index)
    if task_index >= 0 && task_index < @tasks.length
      @tasks[task_index].mark_as_completed
      puts "Tarefa marcada como concluída: #{@tasks[task_index].description}"
    else
      puts "Índice de tarefa inválido."
    end
  end

  def check_due_dates_and_notify
    current_time = current_date_time
    @tasks.each do |task|
      if !task.completed && task.due_date && task.due_time
        if current_time >= task.due_time
          send_notification(task)
        end
      end
    end
  end

  private

  def send_notification(task)
    notification = Libnotify.new do |notify|
      notify.summary = "Tarefa Vencida!"
      notify.body = "Tarefa: #{task.description} está vencida agora."
      notify.timeout = 2 # Tempo em segundos que a notificação ficará visível
    end

    notification.show!
  end
end

task_list = TaskList.new

loop do
  puts "\nEscolha uma ação:"
  puts "1. Adicionar Tarefa"
  puts "2. Listar Tarefas"
  puts "3. Marcar Tarefa como Concluída"
  puts "4. Verificar e Notificar Tarefas Vencidas"
  puts "5. Sair"
  print "Opção: "
  choice = gets.chomp.to_i

  case choice
  when 1
    print "Digite a descrição da tarefa: "
    description = gets.chomp
    print "Digite a prioridade (alta, média, baixa): "
    priority = gets.chomp
    print "Digite o dia de vencimento (DD): "
    due_day = gets.chomp
    print "Digite o mês de vencimento (MM): "
    due_month = gets.chomp
    print "Digite a hora de vencimento (HH): "
    due_hour = gets.chomp
    print "Digite os minutos de vencimento (MM): "
    due_minute = gets.chomp
 
    task_list.add_task(description, priority, due_day, due_month, due_hour, due_minute)
  when 2
    task_list.list_tasks
  when 3
    print "Digite o índice da tarefa a ser marcada como concluída: "
    task_index = gets.chomp.to_i - 1
    task_list.mark_task_as_completed(task_index)
  when 4
    task_list.check_due_dates_and_notify
  when 5
    break
  else
    puts "Opção inválida. Tente novamente."
  end
end
