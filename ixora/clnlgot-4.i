/* clnlgot-4.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Установка тарифов по льготной группе 4 (ТЗ 714)
        скидка 5% на некоторые тарифы, некоторые бесплатно, некоторые льготные
 * RUN
        
 * CALLER
        clnlgot.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-2, 9-1-2-6
 * AUTHOR
        29.01.2004 nadejda
 * CHANGES
        05.07.2005 saltanat - Выборка льгот по счетам.
*/


def shared var g-ofc as char.
def shared var g-today as date.

/*def input parameter*/
def input parameter p-cif   as char.      /* код клиента или пустой - для всех клиентов */
def input parameter p-tarif as char.    /* код тарифа или пустой - для всех тарифов */
def input parameter p-oper  as logical.  /* льготный тариф надо установить (yes) или удалить (no) */


def temp-table t-cif 
  field cif like {1}cif.cif
  index main is primary unique cif.

def temp-table t-tarif like {1}tarif2.

/* собрать нужных клиентов для установки льготного тарифа */
if p-cif = "" then do:
  for each {1}cif where {1}cif.pres = "4" no-lock:
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
  message skip " Клиенты с льготным обслуживанием вида 4 не найдены !" 
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

/* тарифы бесплатные */
def var v-tarif1 as char init "801,807". 
/* тарифы 5% */
def var v-tarif2 as char init "123,130,131,132,133,134,135,136,148,153,158,211,950,951,970,971,972,101,102,104,109,111,112,121,126,137,141,142,147,151,156,157,163,164,165,166,167,168,177,192,201,214,216,401,403,409". 
/* тарифы фиксированные */
def var v-tarif3 as char init "204,205,218,802,804". 

/* собрать все тарифы, по которым будет установлена льгота - в данном случае просто ВСЕ или один указанный */
if p-tarif = "" then do:
  for each {1}tarif2 where not {1}tarif2.pakalp begins "N/A" no-lock:
    if lookup({1}tarif2.str5, v-tarif1) > 0 or lookup({1}tarif2.str5, v-tarif2) > 0 or lookup({1}tarif2.str5, v-tarif3) > 0 then do:
      create t-tarif.
      buffer-copy {1}tarif2 to t-tarif.
    end.
  end.
end.
else do:
  if lookup(p-tarif, v-tarif1) > 0 or lookup(p-tarif, v-tarif2) > 0 or lookup(p-tarif, v-tarif3) > 0 then do:
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
        
        if lookup(t-tarif.str5, v-tarif1) > 0 then do:
          /* льготный тариф - бесплатно */
          assign {1}tarifex.ost = 0
                 {1}tarifex.proc = 0
                 {1}tarifex.min1 = 0
                 {1}tarifex.max1 = 0.
        /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
        for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
           assign {1}tarifex2.ost = 0
                 {1}tarifex2.proc = 0
                 {1}tarifex2.min1 = 0
                 {1}tarifex2.max1 = 0.
        end.
                 
        end.         

        
        if lookup(t-tarif.str5, v-tarif2) > 0 then do:
          /* льготный тариф - 5% скидка на установки тарификатора */
          assign {1}tarifex.ost = t-tarif.ost * 0.95
                 {1}tarifex.proc = t-tarif.proc * 0.95
                 {1}tarifex.min1 = t-tarif.min1 * 0.95
                 {1}tarifex.max1 = t-tarif.max1 * 0.95.
        /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
        for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
            assign {1}tarifex2.ost = t-tarif.ost * 0.95
                 {1}tarifex2.proc = t-tarif.proc * 0.95
                 {1}tarifex2.min1 = t-tarif.min1 * 0.95
                 {1}tarifex2.max1 = t-tarif.max1 * 0.95.
        end.  
        end.         

        if lookup(t-tarif.str5, v-tarif3) > 0 then do:
          /* особые тарифы */
          {1}tarifex.ost = 0.
          case t-tarif.str5 :
            when "204" then do:
              assign {1}tarifex.proc = 0.15
                     {1}tarifex.min1 = 2980
                     {1}tarifex.max1 = 62740.
            end.
            when "205" then do:
              assign {1}tarifex.proc = 0.2
                     {1}tarifex.min1 = 7460
                     {1}tarifex.max1 = 78425.
            end.
            when "218" then do:
              assign {1}tarifex.proc = 0.2
                     {1}tarifex.min1 = 2850
                     {1}tarifex.max1 = 78425.
            end.
            when "802" then do:
              assign {1}tarifex.proc = 0.2
                     {1}tarifex.min1 = 2355
                     {1}tarifex.max1 = 0.
            end.
            when "804" then do:
              assign {1}tarifex.proc = 0.15
                     {1}tarifex.min1 = 2355
                     {1}tarifex.max1 = 0.
            end.
          end.
          /* 05/07/05 saltanat - Если есть льготы по счетам, то их меняем аналогично. */
          for each {1}tarifex2 where {1}tarifex2.cif = {1}tarifex.cif and {1}tarifex2.str5 = {1}tarifex.str5  and {1}tarifex2.stat = 'r' exclusive-lock.
          {1}tarifex2.ost = 0.
          case t-tarif.str5 :
            when "204" then do:
              assign {1}tarifex2.proc = 0.15
                     {1}tarifex2.min1 = 2980
                     {1}tarifex2.max1 = 62740.       
            end.
            when "205" then do:
              assign {1}tarifex2.proc = 0.2
                     {1}tarifex2.min1 = 7460
                     {1}tarifex2.max1 = 78425.       
            end.
            when "218" then do:
              assign {1}tarifex2.proc = 0.2
                     {1}tarifex2.min1 = 2850
                     {1}tarifex2.max1 = 78425.       
            end.
            when "802" then do:
              assign {1}tarifex2.proc = 0.2
                     {1}tarifex2.min1 = 2355
                     {1}tarifex2.max1 = 0.       
            end.
            when "804" then do:
              assign {1}tarifex2.proc = 0.15
                     {1}tarifex2.min1 = 2355
                     {1}tarifex2.max1 = 0.       
            end.
          end. /* case */
         end. /* tarifex2 */ 
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


