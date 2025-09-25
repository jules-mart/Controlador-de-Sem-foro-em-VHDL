# 🚦 Controlador de Semáforo em VHDL

Este projeto RTL implementa um **sistema de controle de semáforo** utilizando **Máquina de Estados Finitos (FSM)** em VHDL.
O objetivo é gerenciar o fluxo de tráfego em um cruzamento, com detecção de veículos, botões de pedestres e modo de emergência.

---

## 📋 Descrição do Projeto

O sistema controla dois eixos de tráfego: **Norte-Sul (NS)** e **Leste-Oeste (EW)**.
A FSM gerencia os estados do semáforo de acordo com sensores de presença de veículos, botões de pedestres e temporizações pré-definidas.
Também existe um **modo de emergência**, que interrompe imediatamente o funcionamento normal.

---

## 🔀 Estrutura da FSM

A FSM é composta pelos seguintes estados:

| Estado          | Descrição                                                                                        | Próximo estado | Condições de transição                                          |
| --------------- | ------------------------------------------------------------------------------------------------ | -------------- | --------------------------------------------------------------- |
| **NS\_VERDE**   | Sinal verde para Norte-Sul. Mantém enquanto houver tráfego ou botão de pedestre acionado (<50s). | NS\_AMARELO    | Tempo = 40s (com tráfego), 10s (sem tráfego) ou 28s (pedestre). |
| **NS\_AMARELO** | Sinal amarelo para Norte-Sul. Duração fixa de 2s.                                                | EW\_VERDE      | Após 2s.                                                        |
| **EW\_VERDE**   | Sinal verde para Leste-Oeste. Regras análogas ao estado NS\_VERDE.                               | EW\_AMARELO    | Mesmas condições de tempo.                                      |
| **EW\_AMARELO** | Sinal amarelo para Leste-Oeste. Duração fixa de 2s.                                              | NS\_VERDE      | Após 2s.                                                        |
| **EMERGÊNCIA**  | Ativado a qualquer momento em caso de emergência ou reset.                                       | NS\_VERDE      | 2s após fim da emergência.                                      |

---

## 🛠️ Componentes Principais

O projeto é dividido em módulos estruturais:

* **Contador de Tempo (`tempo_counter`)**

  * Conta o tempo em segundos para as transições de estado.
  * Entradas: `clk`, `reset_n`, `enable_count`, `clear_count`
  * Saída: `current_time` (6 bits).

* **Comparadores de Tempo (`time_comparator`)**

  * Gera sinais de transição com base em tempos pré-definidos (2, 10, 28, 40, 50 segundos).

* **Registrador de Estado (`state_register`)**

  * Armazena o estado atual da FSM.

* **Controladora**

  * Recebe sensores, botões e comparadores, gerando os sinais de controle para o semáforo.

* **Divisor de Clock**

  * Reduz o clock do sistema (50 Hz) para 1 Hz.

---

## 💡 Funcionalidades

✅ Controle automático de tráfego com base em sensores.
✅ Botões de pedestre para travessia segura.
✅ Temporizações dinâmicas para fluxo eficiente.
✅ Modo de emergência com prioridade máxima.

---

