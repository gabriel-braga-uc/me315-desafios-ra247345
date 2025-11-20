using Base.Threads # Biblioteca padrão para multithreading
using Random

# --- Configuração ---
# Vamos definir um tamanho de array grande o suficiente para que o processamento demore um pouco.
# Se o computador for muito rápido, aumente este número.
const N = 10_000_000 

println("=== Iniciando Benchmark de Paralelismo ===")
println("Número de threads disponíveis: ", Threads.nthreads())

if Threads.nthreads() == 1
    println("⚠️ AVISO: Você está rodando com apenas 1 thread.")
    println("   O exemplo paralelo não será mais rápido que o serial.")
    println("   Reinicie o Julia definindo a variável de ambiente JULIA_NUM_THREADS.\n")
end

# --- Função de Custo Computacional ---
# Esta função simula um trabalho pesado (heavy workload).
# Ela faz cálculos trigonométricos complexos apenas para gastar CPU.
function tarefa_pesada(x)
    return sin(x) * cos(x) + tan(x) * sqrt(abs(x))
end

# --- 1. Execução em SÉRIE (Single-thread) ---
function loop_serial(n)
    resultado = zeros(Float64, n)
    for i in 1:n
        # Cada iteração espera a anterior terminar
        resultado[i] = tarefa_pesada(i)
    end
    return resultado
end

# --- 2. Execução em PARALELO (Multi-thread) ---
function loop_paralelo(n)
    resultado = zeros(Float64, n)
    # A macro @threads divide o intervalo do loop entre os núcleos disponíveis
    Threads.@threads for i in 1:n
        resultado[i] = tarefa_pesada(i)
    end
    return resultado
end

# --- BENCHMARK ---

println("\n1. Aquecendo (Compilação JIT)...")
# O Julia compila na primeira execução. Rodamos uma vez com valor baixo
# para que o tempo de compilação não afete nosso teste de velocidade.
loop_serial(1000)
loop_paralelo(1000)
println("   Aquecimento concluído.")

println("\n2. Rodando em SÉRIE (N = $N)...")
# @time mede o tempo e alocação de memória da expressão a seguir
tempo_serial = @elapsed loop_serial(N)
println("   Tempo Serial: $(round(tempo_serial, digits=4)) segundos")

println("\n3. Rodando em PARALELO (N = $N)...")
tempo_paralelo = @elapsed loop_paralelo(N)
println("   Tempo Paralelo: $(round(tempo_paralelo, digits=4)) segundos")

# --- Resultados ---
println("\n=== Conclusão ===")
if tempo_paralelo < tempo_serial
    speedup = tempo_serial / tempo_paralelo
    println("O código paralelo foi $(round(speedup, digits=2))x mais rápido!")
else
    println("O código paralelo não foi mais rápido. Verifique se JULIA_NUM_THREADS > 1.")
end