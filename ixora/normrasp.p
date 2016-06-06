/* normrasp.p
 * MODULE
        -
 * DESCRIPTION
        мНПЛЮКЭМНЕ (ЦЮСЯЯНБЯЙНЕ) ПЮЯОПЕДЕКЕМХЕ
 * RUN
        яОНЯНА БШГНБЮ ОПНЦПЮЛЛШ, НОХЯЮМХЕ ОЮПЮЛЕРПНБ, ОПХЛЕПШ БШГНБЮ
 * CALLER
        яОХЯНЙ ОПНЖЕДСП, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * SCRIPT
        яОХЯНЙ ЯЙПХОРНБ, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * INHERIT
        яОХЯНЙ БШГШБЮЕЛШУ ОПНЖЕДСП
 * MENU
        оЕПЕВЕМЭ ОСМЙРНБ лЕМЧ оПЮЦЛШ 
 * AUTHOR
        24/09/2004 madiar
 * CHANGES
        20/12/2004 madiar - ХГЛЕМХК ПЮЯВЕР ХМРЕЦПЮКЮ ПЮЯОПЕДЕКЕМХЪ
*/

def var const-e as deci init 2.718281828459045.
def var const-pi as deci init 3.141592653589793.

def input parameter v-x as deci. /* ЮПЦСЛЕМР ПЮЯОПЕДЕКЕМХЪ */
def input parameter v-average as deci. /* ЯПЕДМЕЕ */
def input parameter v-stddeviation as deci. /* ЯРЮМДЮПРМНЕ НРЙКНМЕМХЕ */
def input parameter v-integr as logi. /* no - ОКНРМНЯРЭ ПЮЯОПЕДЕКЕМХЪ, yes - ХМРЕЦПЮК */
def output parameter v-result as deci.

/* ПЮЯВЕР ОКНРМНЯРХ МНПЛЮКЭМНЦН ПЮЯОПЕДЕКЕМХЪ */

if not v-integr then do:
  v-result = exp(const-e,0 - exp((v-x - v-average) / v-stddeviation, 2) / 2) / v-stddeviation / exp(2 * const-pi, 0.5) no-error.
  return.
end.

/*
ПЮЯВЕР ХМРЕЦПЮКЮ МНПЛЮКЭМНЦН ПЮЯОПЕДЕКЕМХЪ

ДКЪ СБЕКХВЕМХЪ РНВМНЯРХ МСФМН СЛЕМЭЬЮРЭ ЬЮЦ Х ОНЦПЕЬМНЯРЭ
*/

def var v-cx as deci.
def var fret as deci.
def var step as deci. /* ЬЮЦ */
def var v-err as deci. /* ОНЦПЕЬМНЯРЭ ПЮЯВЕРЮ */

step = 0.01.
v-err = 0.00000001.
v-cx = v-x.

v-result = 0.
repeat:
  v-cx = v-cx - step / 2.
  run normrasp(v-cx, v-average, v-stddeviation, no, output fret).
  v-result = v-result + step * fret.
  if step * fret < v-err and v-cx < v-average then do: message string(v-cx, "->>>,>>>,>>9.99<<<") view-as alert-box buttons ok. pause. leave. end.
  v-cx = v-cx - step / 2.
end.