# VGA Digital Clock FPGA **PEGAR EL LINK PÚBLICO AQUÍ**

# Primer avance (Semana 9)
## 8/Abr/2026 - 10/Abr/2026
Se conversó entre los integrantes del grupo sobre el diagrama de bloques del proyecto y se investigó con ayuda de inteligencia artificial utilizando referencias de la web como apoyo para el funcionamiento del proyecto del reloj en VGA. Una vez realizada la investigación y se comprendió el flujo se optó por utilizar la pagina web Lucidchart.com para realizar la imagen del diagrama de flujo, la cual se presentó el día 10 de abril del 2026.

# Creación del proyecto en Vivado
## 17/Abr/2026 - 19/Abr/2026
**Gabriel Arguedas:**
Estuve trabajando en vivado y realizando algunos módulos, basandome en el libro de teoría EL3313__Book.pdf y en algunos laboratorios anteriores como los de la calculadora o el semaforo, ademas de que me puse a buscar informacion sobre los debouncer, divisores de reloj, displays de 7 segmentos ya que estos módulos son parte fundamental del funcionamiento del proyecto. Una vez obtuve esa información del libro utilicé la inteligencia artificial para lograr plasmar correctamente la síntesis de vivado y poder crear de una correcta manera (quizá no la mas eficiente) los siguientes módulos:
- clock_divider.v (Corresponde al divisor de reloj, creado para el conteo de segundos)
- debouncer.v (Evita el rebote en los botones y switches de la FPGA)
- display_7seg.v (Muestra la hora y el conteo de los ss, mm y hh en los displays correspondientes)
- parte del top_reloj.v (La parte que se encarga de llevar a cabo el conteo, debouncer, divisor de reloj y mostrar en los displays de 7 segmentos)
- control_hora_manual.v (Se encarga de llevar el conteo en segundos y hacer funcional el modo editor de hora).

También realicé pruebas y simulaciones en vivado para ver como avanzaba el conteo de los ss, mm y hh, esto para verificar que funcionara correctamente, lo cual afortunadamente si funcionó, como ya la simulacion me servía le pasé lo que tenía a los compañeros por el grupo de whatsapp y ahí el compañero Josué hizo la prueba del código en la FPGA y funcionó correctamente.

# Implementación de modulos 
## 24/Abr/2026 - 27/Abr/2026
**Josué Arce Cruz - Mauro Agustin Navarro Acuña:**
Se trabajó en la implementación de los modulos de memoria de video, módulo controlador VGA y módulo generador de imagen, el módulo de control de hora fue implementando por el compañaero Gabriel y valido su funcionamiento.
## Lista de modulos implementados:
- clk_25MHZ: Moduó encargado de generar el reloj para la señal VGA el cual usa un clock de 25MHz.
- vga_sync: Genera las señales de sincronización VGA usando contaddores horizontales y verticales. Estos contadores recorren la pantalla siguiendo los tiempos del protocolo VGA como lo son **Front Porch, Sync, Back Porch** y producen señales **hsync** y **vsync** para indicar el final de una linea y de cada frame. La señal **video_en** indica cuando se encuentra dentro de la zona visible donde se pueden dibujar píxeles.
- img_gen: Recorre los píxeles de la pantalla y genera la imagen final que será almacenada en la VRAM. Utiliza una imagen de fondo y dibuja encima un reloj dijital consulta la font_rom para determinar que píxeles de cada digito deben encenderse y como se ven los numeros. Además, implementa un modo de edición con parpadeo para resaltas cuando se encuentre modificando horas, minutos  y segundos, según sea seleccionado.
- font_rom: Encargado de almacenar la representación en píxeles de cada digito a mostrar en el reloj. Cada dirección corresponde a una fila especifica de un carácter, el módulo devuelve 8 bits que indican que píxeles deben encenderse o apagarse para dibujarse en pantalla.
Por ejemplo: 8'h03
Significa: Digito 0, fila 3 de ese digito, por lo cual indica 8'h03: data = 8'b01100110
- BRAM: Funciona como una memoria de video encargada de almacenar la imagen completa que será mostrada en pantalla. Utiliza dos puertos: Puerto A de escritura de píxeles y Puerto B lectura de píxeles.
El puerto A permite que otros modulos escriban en el, por ejemplo cuando se modifica la hora y el puerto B permite que el controlador VGA consulte continuamente los colores de cada píxel para ser enviados al monitor. Además la memoria se inicializa con una imagen de fondo utilizando un archivo (.coe).
- top_reloj: Este modulo fue reutilizado ya que fue implementado por el compañero Gabriel para probar el control de hora, las modificaciones implementadas son simplemente que siga funcionando como modulo top en el cual se instanciaron los modulos anteriormente mencionados. 
Por ultimo se realizó la unión de todos los modulos nuevos con los ya implementados por el compañero Gabriel, se realizó la sintetización de cada uno de ellos y se validó el correcto funcionamiento del proyecto usando uno de los monitores del laboratorio. 
