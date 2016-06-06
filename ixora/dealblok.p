/* dealblok.p
 * MODULE
        Модуль ЦБ 
 * DESCRIPTION
        Залоговые операции по ЦБ 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dealval2.p
 * MENU
        11-9-2 
 * BASES
        BANK 
 * AUTHOR
        01.07.08 marinav
 * CHANGES
*/

{mainhead.i MMD}

define variable v-rate like crc.rate[1].
define variable v-code like crc.code.
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 360.

def var v-rdt as date.
def var v-cdt as date.
def var v-titl as char.



def var v-sel as char.
def var prz as inte.

  run sel ("ЗАЛОГОВЫЕ ОПРЕРАЦИИ :",
         " 1. Обременение ценных бумаг    | 2. Блокирование ценных бумаг  | 3. Выход ").
  v-sel = return-value.
  case v-sel:

     when "1" then  assign prz = 1.
     when "2" then  assign prz = 2.
     when "3" then return.
  end case.


def var v-deal like deal.deal.

/*общая часть*/
def var v-scugrp   like deal.grp.
def var v-gl       like gl.gl.
def var v-gldes    like gl.des.

/*Сведения о ЦБ*/
def var v-nin      like dealref.nin.
def var v-cbname   like deal.rem[3].
def var v-atval    like deal.atvalueon[3].
def var v-type     like dealref.type.
def var v-sort     like dealref.sort.
def var v-ncrc     like dealref.ncrc.
def var v-intrate  like deal.intrate.
def var v-issuedt  like dealref.issuedt.
def var v-maturedt like dealref.maturedt.
def var v-paydt    like dealref.paydt.
def var v-dval2    as int.
def var v-dval3    as int.
def var v-base     like deal.base.
def var v-inttype  like deal.inttype.
def var v-lpaydt   like dealref.lpaydt.

/*Сведения о сделке*/
def var v-ccrc     as deci.
def var v-col      like deal.ncrc[2].
def var v-profit   like deal.profit.
def var v-bcrc     as dec.
def var v-dealsum  as dec.
def var v-crc      like crc.crc.
def var v-regdt    as date.
def var v-valdt    like deal.valdt.
def var v-kontr    like deal.broke.

def var v-com      as char.
def var v-lsch     as char.
def var v-cif      like cif.cif.


form v-deal      label "Номер сделки" space (16)
     
     v-scugrp    label "Группа......" format "zz9" skip
     
     v-cif       label "Код клиента." format "x(8)" space (4)
     v-lsch      label "Лиц. счет..." format "x(20)" skip
 
     v-nin       label "НИН........." skip
     v-cbname    label "Наим-ие ЦБ.." format "x(50)" skip
     v-atval     label "Эмитент....." format 'x(50)' skip
     v-type      label "ТипЭмит....." format "99" space(24)
         v-ccrc      label "Чистая цена." format ">,>>9.99" skip
     v-sort      label "ВидЭмит....." format "99" space(24)
         v-col       label "Количество.." format ">>,>>>,>>9" skip
     v-ncrc      label "Номинал ЦБ.." format ">>,>>>,>>>,>>9" space(12)
         v-profit    label "Доходность.." skip
     v-intrate   label "Купон......." format ">>9.9999" space(18)
         v-bcrc      label "Грязная цена" format ">>>,>>>,>>9.99" skip
     v-issuedt   label "Дата выпуска" format "99/99/9999" space(16)
         v-dealsum   label "Сумма сделки" format ">>>,>>>,>>9.99" skip
     v-maturedt  label "Дата погашен" format "99/99/9999" space(16)
         v-crc       label "Валюта......" format ">9" skip
     v-paydt     label "Дата выплаты купона...." format "99/99/9999" space(5)
         v-lpaydt    label "Дата посл. выплаты." format "99/99/9999" skip
     v-dval2     label "Дней до погашения......" format ">>>,>>>,>>9" space(4)
         v-regdt     label "Дата сделки." format "99/99/9999" skip
     v-dval3     label "Дней до выплаты купона." format ">>9" space(12)
         v-valdt     label "Дата валютир" format "99/99/9999" skip
     v-base      label "База..................." skip
     v-inttype   label "Тип ЦБ................." validate(v-inttype = "A" or v-inttype = "D"," ") space(14)
     v-kontr     label "Контрагент.." format "x(10)" skip(1)
      with frame deal row 5 side-label centered   width 80.


          clear frame deal.
    update v-deal with frame deal.
    find first deal where deal.deal eq v-deal no-lock no-error.
    if not avail deal then do:
        message "Не найдена сделка " v-deal.
        pause 100.
        undo, retry.
    end.
      


    v-cif = deal.cif.
    find first cif where cif.cif eq deal.cif no-error.
    if avail cif then v-lsch = cif.head[1]. 
    v-scugrp = deal.grp.
    v-nin = deal.nin.
    v-base = deal.base.
    v-ccrc = deal.ccrc.
    v-col = deal.ncrc[2].
    v-profit = deal.profit.
    v-crc = deal.crc.
    v-regdt = deal.regdt.
    v-valdt = deal.valdt.
    v-kontr = deal.broke.
    
    find first dealref where dealref.nin eq deal.nin no-lock no-error.
    v-cbname = dealref.cb.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
    v-paydt = dealref.paydt.
    v-lpaydt = dealref.lpaydt.
    v-inttype = dealref.inttype.
    
    v-dval2 = v-maturedt - v-regdt.
    v-dval3 = v-paydt - v-regdt.
    
    v-bcrc = (v-ccrc * v-ncrc / 100) + v-ncrc * v-intrate / 100 / int(entry(2, v-base, "/")) * (v-regdt - v-lpaydt).
    v-dealsum = v-col * v-bcrc.
    


        displ v-deal v-scugrp v-cif v-lsch v-nin v-cbname v-atval v-type
            v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt
            v-base v-inttype v-col v-profit v-ccrc v-crc v-regdt
            v-valdt v-kontr v-dval2 v-dval3 v-dealsum v-lpaydt
            v-bcrc with frame deal.


      if prz = 1 then v-titl = 'ОБРЕМЕНЕНИЕ'. else v-titl = 'БЛОКИРОВАНИЕ'.

      {jabrw.i 
      &start     = " "
      &head      = "dealblock"
      &headkey   = "deal"
      &index     = "coddedt"
      &formname  = "dealblok"
      &framename = "deal1"
      &where     = " code = prz and deal = deal.deal "
      &addcon    = "true"
      &deletecon = "true"
      &precreate = " "
      &postadd   = "  dealblock.code = prz. dealblock.deal = deal.deal. dealblock.whn = g-today. dealblock.who = g-ofc. 
                      dealblock.amount = deal.prn. dealblock.counts = deal.ncrc[2].
                      displ dealblock.deal dealblock.whn dealblock.who with frame deal1 scrollable.        
                      update dealblock.rdt dealblock.cdt dealblock.amount dealblock.counts with frame deal1."       
             
      &prechoose = " "
      &postdisplay = " "
      &display   = " dealblock.deal dealblock.rdt dealblock.cdt dealblock.amount dealblock.counts dealblock.whn dealblock.who " 
      &highlight = " dealblock.deal "
      &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                            then do transaction on endkey undo, leave:
                                    update dealblock.rdt dealblock.cdt dealblock.amount dealblock.counts with frame deal1 scrollable .
                                    message 'F4 - Выход '.
                                    displ dealblock.deal dealblock.rdt dealblock.cdt dealblock.amount dealblock.counts dealblock.whn dealblock.who with frame deal1.
                    end. "
      &end = "hide frame deal1."
      }
      hide message.


 for each dealblock where dealblock.rdt = ? and  dealblock.cdt = ? exclusive-lock.
   delete dealblock.
 end.


