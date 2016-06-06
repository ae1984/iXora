/* clnlgot-1.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Установка льготных тарифов для вкладчиков ПФ АБН АМРО
        скидка 5% на некоторые тарифы, некоторые бесплатно, некоторые льготные
 * RUN
        
 * CALLER
        clnlgot.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-2, 9-1-2-6
 * AUTHOR
        13.01.2004 nadejda
 * CHANGES
        05.07.2005 saltanat - Выборка льгот по счетам.
*/


def shared var g-ofc as char.
def shared var g-today as date.

/*def input parameter*/
def input parameter p-cif as char.      /* код клиента или пустой - для всех клиентов */
def input parameter p-tarif as char.    /* код тарифа или пустой - для всех тарифов */
def input parameter p-oper as logical.  /* льготный тариф надо установить (yes) или удалить (no) */


def temp-table t-cif 
  field cif like {1}cif.cif
  field sts as char
  index main is primary unique cif.

def temp-table t-tarif like {1}tarif2.

/* собрать нужных клиентов для установки льготного тарифа */
if p-cif = "" then do:
  for each {1}cif where {1}cif.pres = "3" no-lock:
    create t-cif.
    t-cif.cif = {1}cif.cif.
  end.
end.
else do:
  find {1}cif where {1}cif.cif = p-cif no-lock no-error.
  if avail {1}cif then do:
    create t-cif.
    t-cif.cif = p-cif.
  end.
  else do:
    message skip " Клиент" p-cif "не найден !" 
            skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
  end.
end.

find first t-cif no-lock no-error.
if not avail t-cif then do:
  message skip " Клиенты с льготным обслуживанием вида 3 не найдены !" 
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

for each t-cif:
  find {1}sub-cod where {1}sub-cod.sub = "cln" and {1}sub-cod.d-cod = "clnsts" and {1}sub-cod.acc = t-cif.cif no-lock no-error.
  t-cif.sts = {1}sub-cod.ccode.
end.


def var v-fiz1 as char init "103,105,208,209,213,159,125,419,402,212,201,202,111,195,429,401". /* тарифы 5% физлица */
def var v-fiz2 as char init "904". /* тарифы 10% физлица */
def var v-jur1 as char init "101,102,104,109,156,157,147,121,141,142,163,164,214,170,201,216,111,403,409,401,151,126,112,192,165,166,167,168,204,205,218,123,132,158,430". /* тарифы 5% юрлица */

/* собрать все тарифы, по которым будет установлена льгота -  ВСЕ или один указанный */
if p-tarif = "" then do:
  for each {1}tarif2 where not {1}tarif2.pakalp begins "N/A" no-lock:
    if lookup({1}tarif2.str5, v-fiz1 + "," + v-fiz2 + "," + v-jur1) > 0 then do:
      create t-tarif.
      buffer-copy {1}tarif2 to t-tarif.
    end.
  end.
end.
else do:
  if lookup(p-tarif, v-fiz1 + "," + v-fiz2 + "," + v-jur1) > 0 then do:
    find {1}tarif2 where {1}tarif2.str5 = p-tarif and not {1}tarif2.pakalp begins "N/A" no-lock no-error.
    if avail {1}tarif2 then do:
      create t-tarif.
      buffer-copy {1}tarif2 to t-tarif.
    end.
    else do:
      message skip " Тариф" p-tarif "не найден или не активен !" 
              skip(1) view-as alert-box button ok title " ОШИБКА ! ".
      return.
    end.
  end.
end.


find first t-tarif no-lock no-error.
if not avail t-tarif then return.


/* создать/обновить записи с льготным тарифом */
for each t-cif:
  c-tarif:
  for each t-tarif:
    do transaction on error undo, retry:
      find {1}tarifex where {1}tarifex.cif = t-cif.cif and {1}tarifex.str5 = t-tarif.str5 no-lock no-error.
      if avail {1}tarifex and substr({1}tarifex.who, 1, 1) <> "A" then 
        next c-tarif.   /* льготные тарифы, установленные вручную, не меняем! */

      if (t-cif.sts = "1" and lookup(t-tarif.str5, v-fiz1 + "," + v-fiz2) = 0) or
         (t-cif.sts = "0" and lookup(t-tarif.str5, v-jur1) = 0) then next.

      if p-oper then do:  /* создать/обновить льготу */
        if avail {1}tarifex then find current {1}tarifex exclusive-lock.
        else do:
          create {1}tarifex.
          assign {1}tarifex.cif = t-cif.cif
                 {1}tarifex.str5 = t-tarif.str5.
        end.

        assign {1}tarifex.kont = t-tarif.kont
               {1}tarifex.pakalp = t-tarif.pakalp
               {1}tarifex.crc = t-tarif.crc
               {1}tarifex.who = "A" + g-ofc /* признак 'установлено автоматически по льготной группе обслуживания' */
               {1}tarifex.whn = g-today.
               {1}tarifex.stat = 'r'.

        /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
        for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
            assign {1}tarifex2.kont = t-tarif.kont
               {1}tarifex2.pakalp = t-tarif.pakalp
               {1}tarifex2.crc = t-tarif.crc
               {1}tarifex2.who = "A" + g-ofc /* признак 'установлено автоматически по льготной группе обслуживания' */
               {1}tarifex2.whn = g-today.
               {1}tarifex2.stat = 'r'. 
        end.
        
        if lookup(t-tarif.str5, v-fiz1 + "," + v-jur1) > 0 then do:
          /* льготный тариф - 5% скидка на установки тарификатора */
          assign {1}tarifex.ost = t-tarif.ost * 0.95
                 {1}tarifex.proc = t-tarif.proc * 0.95
                 {1}tarifex.max1 = t-tarif.max1 * 0.95
                 {1}tarifex.min1 = t-tarif.min1 * 0.95.
        /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
        for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
            assign {1}tarifex2.ost = t-tarif.ost * 0.95
                 {1}tarifex2.proc = t-tarif.proc * 0.95
                 {1}tarifex2.max1 = t-tarif.max1 * 0.95
                 {1}tarifex2.min1 = t-tarif.min1 * 0.95.
        end.         
        end.         

        if lookup(t-tarif.str5, v-fiz2) > 0 then do:
          /* льготный тариф - 10% скидка на установки тарификатора */
          assign {1}tarifex.ost = t-tarif.ost * 0.9
                 {1}tarifex.proc = t-tarif.proc * 0.9
                 {1}tarifex.max1 = t-tarif.max1 * 0.9
                 {1}tarifex.min1 = t-tarif.min1 * 0.9.
        /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
        for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
            assign {1}tarifex2.ost = t-tarif.ost * 0.9
                 {1}tarifex2.proc = t-tarif.proc * 0.9
                 {1}tarifex2.max1 = t-tarif.max1 * 0.9
                 {1}tarifex2.min1 = t-tarif.min1 * 0.9.
        end.         
        end.         
        
        release {1}tarifex2.
        release {1}tarifex.
      end.
      else do:
        /* удалить */
        if avail {1}tarifex then do:
          find current {1}tarifex exclusive-lock.
          delete {1}tarifex.
        end.
      end. /* p-oper */
    end. /* do transaction */
  end. /* for each t-tarif */
end. 


