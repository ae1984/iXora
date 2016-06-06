/* cif-info.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Редактирование дополнительной информации о физлице
 * RUN
        верхнее меню "ИнфоФЛ"
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-2
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
        25.02.2004 nadejda - обработка отсутствия данных в адресе
        07/09/2004 madiar  - добавил примечания
        14/09/2005 madiar  - добавил результат оповещения
        25/02/2010 galina - добавила ввод области и почтового индекса в адресе
        26/02/2010 galina - явно указала ширину фрейма
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
def var v-note    as char.
def var v-resn    as char.

def var v-index1 as char.
def var v-index2 as char.
def var v-region1 as char.
def var v-region2 as char.

def frame f-cifinfo
  "--------------------------------------- АДРЕС ПРОПИСКИ --------------------------------" skip
  " Область                         город          ул/мкр" skip
  v-region1 no-label format "x(30)"
  v-city1   no-label format "x(15)"
  v-street1 no-label format "x(30)" skip(2)
  " дом        кв   почтовый индекс" skip
  v-house1  no-label format "x(10)"
  v-apart1  no-label format "x(10)"
  v-index1  no-label format "x(10)" skip

  "---------------------------------- АДРЕС ФАКТИЧ.ПРОЖИВАНИЯ ----------------------------" skip
  " Область                         город          ул/мкр" skip
  v-region2 no-label format "x(30)"
  v-city2   no-label format "x(15)"
  v-street2 no-label format "x(30)" skip(2)
  " дом        кв   почтовый индекс" skip
  v-house2  no-label format "x(10)"
  v-apart2  no-label format "x(10)"
  v-index2  no-label format "x(10)" skip

  "--- МЕСТО РАБОТЫ ---" skip
  v-jobrnn  label "   БИН" format "x(12)"
  v-job label "НАИМ-Е" format "x(39)" skip
  v-jobadr  label " АДРЕС" format "x(50)" skip

  "--- ТЕЛЕФОНЫ ---" skip
  v-htel    label " ДОМАШ" format "x(20)"
  v-mtel    label "  МОБИЛ" format "x(20)" at 30 skip
  v-jtel    label " РАБОЧ" format "x(20)"
  v-ctel    label "КОНТАКТ" format "x(20)" at 30 skip

  "ПРИМЕЧ:" DCOLOR 2 v-note no-label at 9 view-as editor size 60 by 2 skip
  "РЕЗ-Т :" DCOLOR 2 v-resn no-label at 9 view-as editor size 60 by 2

  with overlay centered row 3 side-labels width 100 title " КЛИЕНТ : " + cif.cif + " " + cif.sname + " ".


if cif.dnb <> "" then do:
  v-str = entry(1, cif.dnb, "|").
  if num-entries(v-str,'^') = 4 then do:
      v-city1 = entry(1, v-str, v-delim).
      if num-entries(v-str, v-delim) > 1 then v-street1 = entry(2, v-str, v-delim).
      if num-entries(v-str, v-delim) > 2 then v-house1 = entry(3, v-str, v-delim).
      if num-entries(v-str, v-delim) > 3 then v-apart1 = entry(4, v-str, v-delim).
  end.
  if num-entries(v-str,'^') = 7 then do:
      v-region1 =  entry(2, v-str, v-delim).
      v-city1 = entry(3, v-str, v-delim).
      v-street1 = entry(4, v-str, v-delim).
      v-house1 = entry(5, v-str, v-delim).
      v-apart1 = entry(6, v-str, v-delim).
      v-index1 = entry(7, v-str, v-delim).
  end.
  if num-entries(cif.dnb, "|") > 1 then do:
    v-str = entry(2, cif.dnb, "|").
    if num-entries(v-str,'^') = 4 then do:
       v-city2 = entry(1, v-str, v-delim).
       if num-entries(v-str, v-delim) > 1 then v-street2 = entry(2, v-str, v-delim).
       if num-entries(v-str, v-delim) > 2 then v-house2 = entry(3, v-str, v-delim).
       if num-entries(v-str, v-delim) > 3 then v-apart2 = entry(4, v-str, v-delim).
    end.
    if num-entries(v-str,'^') = 7 then do:
       v-region2 = entry(2, v-str, v-delim).
       v-city2 = entry(3, v-str, v-delim).
       v-street2 = entry(4, v-str, v-delim).
       v-house2 = entry(5, v-str, v-delim).
       v-apart2 = entry(6, v-str, v-delim).
       v-index2 = entry(7, v-str, v-delim).
    end.


    if num-entries(cif.dnb, "|") > 2 then v-note = trim(entry(3, cif.dnb, "|")).
    if num-entries(cif.dnb, "|") > 3 then v-resn = trim(entry(4, cif.dnb, "|")).

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

displ v-resn with frame f-cifinfo.

update
  v-region1
  v-city1
  v-street1
  v-house1
  v-apart1
  v-index1
  v-region2
  v-city2
  v-street2
  v-house2
  v-apart2
  v-index2
  v-jobrnn
  v-job
  v-jobadr
  v-htel
  v-jtel
  v-mtel
  v-ctel
  v-note
  with frame f-cifinfo.

if v-city1 entered or v-street1 entered or v-house1 entered or v-apart1 entered or
   v-city2 entered or v-street2 entered or v-house2 entered or v-apart2 entered or
   v-jobrnn entered or v-job entered or v-jobadr entered or
   v-htel entered or v-jtel entered or v-mtel entered or v-ctel entered or v-note entered then do transaction:

  if v-resn <> '' then do:
    message "По клиенту есть данные в строке результата оповещения.~nПри сохранении изменений они будут утеряны.~nПродолжить?"
            view-as alert-box question buttons yes-no title " Внимание! " update choice as logical.
    if not choice then return.
  end.

  find current cif exclusive-lock.
  v-region1 = trim(v-region1).
  v-city1   = trim(v-city1).
  v-street1 = trim(v-street1).
  v-house1  = trim(v-house1).
  v-apart1  = trim(v-apart1).
  v-index1 = trim(v-index1).
  v-region2 = trim(v-region2).
  v-city2   = trim(v-city2).
  v-street2 = trim(v-street2).
  v-house2  = trim(v-house2).
  v-apart2  = trim(v-apart2).
  v-index2 = trim(v-index2).
  v-job     = trim(v-job).
  v-jobrnn  = trim(v-jobrnn).
  v-jobadr  = trim(v-jobadr).
  v-htel    = trim(v-htel).
  v-mtel    = trim(v-mtel).
  v-jtel    = trim(v-jtel).
  v-ctel    = trim(v-ctel).
  v-note    = trim(v-note).
  cif.dnb = 'Казахстан' + v-delim + v-region1 + v-delim + v-city1 + v-delim + v-street1 + v-delim + v-house1 + v-delim + v-apart1 + v-delim + v-index1 + "|" +
            'Казахстан' + v-delim + v-region2 + v-delim + v-city2 + v-delim + v-street2 + v-delim + v-house2 + v-delim + v-apart2 + v-delim + v-index2 + "|" +
            v-note.
 cif.addr[2] = 'Казахстан' + ',' + v-region1 + ',' + v-city1 + ',' + v-street1 + ',' + v-house1 + ',' + v-apart1 + ',' + v-index1.

 /* if v-city1 = "" then cif.addr[2] = "".
                  else cif.addr[2] = v-city1.
  if v-street1 <> "" then do:
    if cif.addr[2] <> "" then cif.addr[2] = cif.addr[2] + ", ".
    cif.addr[2] = cif.addr[2] + v-street1.
  end.
  if v-house1 <> "" then do:
    if cif.addr[2] <> "" then cif.addr[2] = cif.addr[2] + ", ".
    cif.addr[2] = cif.addr[2] + "д." + v-house1.
  end.
  if v-apart1 <> "" then do:
    if cif.addr[2] <> "" then cif.addr[2] = cif.addr[2] + ", ".
    cif.addr[2] = cif.addr[2] + "кв." + v-apart1.
  end. */

  cif.item = v-jobrnn + "|" + v-jobadr.
  cif.ref[8] = v-job.

  cif.tel  = v-htel.
  cif.fax  = v-mtel.
  cif.tlx  = v-jtel.
  cif.btel = v-ctel.

end.

release cif.
