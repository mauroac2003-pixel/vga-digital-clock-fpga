# VGA Digital Clock FPGA **PEGAR EL LINK PÚBLICO AQUÍ**

# Primer avance (Semana 9)
8/Abr/2026 - 10/Abr/2026
Se conversó entre los integrantes del grupo sobre el diagrama de bloques del proyecto y se investigó con ayuda de inteligencia artificial utilizando referencias de la web como apoyo para el funcionamiento del proyecto del reloj en VGA. Una vez realizada la investigación y se comprendió el flujo se optó por utilizar la pagina web Lucidchart.com para realizar la imagen del diagrama de flujo, la cual se presentó el día 10 de abril del 2026.

# Creación del proyecto en Vivado
17/Abr/2026 - 19/Abr/2026
Gabriel Arguedas: Estuve trabajando en vivado y realizando algunos módulos, basandome en el libro de teoría EL3313__Book.pdf y en algunos laboratorios anteriores como los de la calculadora o el semaforo, ademas de que me puse a buscar informacion sobre los debouncer, divisores de reloj, displays de 7 segmentos ya que estos módulos son parte fundamental del funcionamiento del proyecto. Una vez obtuve esa información del libro utilicé la inteligencia artificial para lograr plasmar correctamente la síntesis de vivado y poder crear de una correcta manera (quizá no la mas eficiente) los siguientes módulos:
- clock_divider.v (Corresponde al divisor de reloj, creado para el conteo de segundos)
- debouncer.v (Evita el rebote en los botones y switches de la FPGA)
- display_7seg.v (Muestra la hora y el conteo de los ss, mm y hh en los displays correspondientes)
- parte del top_reloj.v (La parte que se encarga de llevar a cabo el conteo, debouncer, divisor de reloj y mostrar en los displays de 7 segmentos)
- control_hora_manual.v (Se encarga de llevar el conteo en segundos y hacer funcional el modo editor de hora)
También realicé pruebas y simulaciones en vivado para ver como avanzaba el conteo de los ss, mm y hh, esto para verificar que funcionara correctamente, lo cual afortunadamente si funcionó, como ya la simulacion me servía le pasé lo que tenía a los compañeros por el grupo de whatsapp y ahí el compañero Josué hizo la prueba del código en la FPGA y funcionó correctamente.
