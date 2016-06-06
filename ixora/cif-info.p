/* cif-info.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Просмотр дополнительной информации о физлице
 * RUN
        верхнее меню "ИнфоФЛ"
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-1
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
        25.02.2004 nadejda - обработка отсутствия данных в адресе
        11.12.2012 evseev - tz625
*/

def shared var s-cif like cif.cif.

find cif where cif.cif = s-cif no-lock no-error.
if not avail cif then do:
  return.
end.


def var v-str as char.
def var v-delim as char init "^".
def var v-city1   as char.
def var v-city2   as char.
def var v-street1 as char.
def var v-street2 as char.
def var v-house1  as char.
def var v-house2  as char.
def var v-apart1  as char.
def var v-apart2  as char.
def var v-job     as char.
def var v-jobrnn  as char.
def var v-jobadr  as char.
def var v-htel    as char.
def var v-jtel    as char.
def var v-mtel    as char.
def var v-ctel    as char.


def frame f-cifinfo
  "--- АДРЕС ПРОПИСКИ ---" skip
  " город          ул/мкр                         дом        кв" skip
  v-city1   no-label format "x(15)"
  v-street1 no-label format "x(30)"
  v-house1  no-label format "x(10)"
  v-apart1  no-label format "x(10)" skip(1)

  "--- АДРЕС ФАКТИЧ.ПРОЖИВАНИЯ ---" skip
  " город          ул/мкр                         дом        кв" skip
  v-city2   no-label format "x(15)"
  v-street2 no-label format "x(30)"
  v-house2  no-label format "x(10)"
  v-apart2  no-label format "x(10)" skip(1)

  "--- МЕСТО РАБОТЫ ---" skip
  v-jobrnn  label "   БИН" format "x(12)" skip
  v-job     label "НАИМ-Е" format "x(50)" skip
  v-jobadr  label " АДРЕС" format "x(50)" skip(1)

  "--- ТЕЛЕФОНЫ ---" skip
  v-htel    label " ДОМАШ" format "x(20)"
  v-mtel    label "  МОБИЛ" format "x(20)" at 30 skip
  v-jtel    label " РАБОЧ" format "x(20)"
  v-ctel    label "КОНТАКТ" format "x(20)" at 30 skip

  with overlay centered row 4 side-labels title " КЛИЕНТ : " + cif.cif + " " + cif.sname + " ".


if cif.dnb <> "" then do:
  v-str = entry(1, cif.dnb, "|").
  v-city1 = entry(1, v-str, v-delim).
  if num-entries(v-str, v-delim) > 1 then v-street1 = entry(2, v-str, v-delim).
  if num-entries(v-str, v-delim) > 2 then v-house1 = entry(3, v-str, v-delim).
  if num-entries(v-str, v-delim) > 3 then v-apart1 = entry(4, v-str, v-delim).
  if num-entries(cif.dnb, "|") > 1 then do:
    v-str = entry(2, cif.dnb, "|").
    v-city2 = entry(1, v-str, v-delim).
    if num-entries(v-str, v-delim) > 1 then v-street2 = entry(2, v-str, v-delim).
    if num-entries(v-str, v-delim) > 2 then v-house2 = entry(3, v-str, v-delim).
    if num-entries(v-str, v-delim) > 3 then v-apart2 = entry(4, v-str, v-delim).
  end.
end.

if cif.item <> "" then do:
  v-jobrnn = entry(1, cif.item, "|").
  if num-entries(cif.item, "|") > 1 then v-jobadr = entry(2, cif.item, "|").
end.

v-job = cif.ref[8].
v-htel = cif.tel.
v-mtel = cif.fax.
v-jtel = cif.tlx.
v-ctel = cif.btel.


displ
  v-city1
  v-city2
  v-street1
  v-street2
  v-house1
  v-house2
  v-apart1
  v-apart2
  v-job
  v-jobrnn
  v-jobadr
  v-htel
  v-jtel
  v-mtel
  v-ctel
  with frame f-cifinfo.

pause.


