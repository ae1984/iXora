/* MT998_400.p
 * MODULE
       оКЮРЕФМЮЪ ЯХЯРЕЛЮ
 * DESCRIPTION
        яНАХПЮЕЛ ЯВЕРЮ ОН ТХКХЮКЮЛ
 * RUN
        яОНЯНА БШГНБЮ ОПНЦПЮЛЛШ, НОХЯЮМХЕ ОЮПЮЛЕРПНБ, ОПХЛЕПШ БШГНБЮ
 * CALLER
        MT998_400_out.p
 * SCRIPT
        яОХЯНЙ ЯЙПХОРНБ, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * INHERIT
        яОХЯНЙ БШГШБЮЕЛШУ ОПНЖЕДСП
 * MENU

 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK TXB COMM
 * CHANGES
        24.07.2008 galina - ОЕПЕЙНЛОХКЪЖХЪ ОНЯКЕ ГЮЦПСГЙХ МНБНИ РЮАКХЖШ Б comm
        25.07.2008 galina - ЯНАПЮРЭ ЯВЕРЮ чк НРЙП/ГЮЙП Б ОПЕДШДСЫХИ НОЕПДЕМЭ
        01.12.2008 galina - находим с справочнике список пользователей для рассылки ошибок по выгрузке
        02.12.2008 galina - список рассылки почты об ошибках возвращается параметром
                            не берем корсчета банков - по законодательству они не включаются в сообщения
        10.12.2008 galina - информация выдается и по счетам со статусом А
        19.01.2009 galina - выдаем информацию и по текущим счетам ФЛ нерезидента
        03.02.2009 galina - обработка выходных дней, выгружаем информацию за пятницу в воскресенье, если в выходные было первое число
        04.02.2009 galina - указала базу txb для таблицы cls
        04.02.2009 galina - добавила группу счетов 437
        20.03.2009 galina - добавила группу счетов 173,174
        16.04.2009 galina - не отправляем уведомления по 20-тизначным счетам до 02/11/2009
        22.05.2009 galina - отправляем уведомление о закрытии 20-тизначного счета
        27.05.2009 galina - БИК у 20-тизначного счета указываем новый
        23.06.2009 galina - закоментировала выгрузку по закрытию 20-тизначных счетов
        14/01/2010 galina - не выгружаем информацию по закрытию счета ФЛ нерезидента, открытого до 20/01/2009
        27/01/2010 galina - добавила ЛОРО-счета 101,111,194,195
        17/03/2010 galina - добавила счета гарантии 397 и 396
        31/03/2010 galina - добавила группы счетов 160,161,247,248
        07/04/2010 galina - оптимизировала поиск по счетам
        20/10/2010 galina - список групп счетов вынесла в справочник
        27/06/2011 evseev - переход на ИИН/БИН
        30.07.2012 evseev - ТЗ-1468
        16.10.2012 evseev - исправил ошибку по ТЗ-1468
        19.10.2012 evseev - заявка #1390
        30.01.2013 evseev - tz-1646
        28.03.2013 evseev - tz-1774
*/

/*def input parameter p-dt as date.*/
/*"437,478,479,480,481,482,483,484,485,486,487,488,489,237,151,152,153,154,155,156,157,158,171,172,173,174,175,204,202,208,222,232,242,101,111,194,195,397,396,160,161,247,248"*/
def output parameter p-mlist as char.

{chbin_txb.i}

def shared temp-table t-acc
 field jame as char
 field bik as char
 field acc as char
 field acctype as char
 field opertype as char
 field rnn as char
 field bin as char
 field dt as date.

def var v-opertype as char.
def var v-acctype as char.
def var v-dt as date.
def var v-list as char.
def var v-listfl as char.
def var v-listul as char.
/**/
p-mlist = "".
find first txb.sysc where txb.sysc.sysc = "inkmail" no-lock no-error.
p-mlist = txb.sysc.chval.


find txb.sysc where txb.sysc.sysc = 'CLECOD' no-lock no-error.
v-dt = ?.
v-opertype = "".
v-acctype = "".

empty temp-table t-acc.

find last txb.cls where txb.cls.del no-lock no-error.

v-list = ''.
v-listul = ''.
v-listfl = ''.

find first pksysc where pksysc.sysc = 'MT998' no-lock no-error.
/*
518,519,520,437,478,479,480,481,482,483,484,485,486,487,488,489,237,151,152,153,154,155,156,157,158,171,
172,173,174,175,204,202,208,222,232,242,101,111,194,195,397,396,160,161,247,248,176,177,518,519,520,
130,131,132,249,138,139,140,137,142,138,139,140,143,144,145,138,139,140,143,144,145
*/
if avail pksysc and trim(pksysc.chval) <> '' then v-listul = pksysc.chval. else return.


find first pksysc where pksysc.sysc = 'MT998fl' no-lock no-error.
/*A22,A23,A24,A01,A02,A03,A04,A05,A06,202,204,222,208,249,246,247,248,138,139,140*/
if avail pksysc and trim(pksysc.chval) <> '' then v-listfl = pksysc.chval. else return.

v-list = v-listul + "," + v-listfl.

for each txb.aaa no-lock:
  if lookup(txb.aaa.lgr,v-list) = 0 then next.

  if txb.aaa.sta = "C" then do:
     find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' and txb.sub-cod.rdt = txb.cls.whn no-lock no-error.
     if not avail txb.sub-cod then next.
  end.
  if txb.aaa.sta <> "C" and txb.aaa.regdt <> txb.cls.whn then next.

  /*if lookup(aaa.aaa,"KZ62470192204A907916,KZ56470192205A908816,KZ77470292204A908116,KZ92470392204A908316,KZ51470292206A908616,KZ72470192205A908916") = 0 then next.*/


  /* для проталкивания счетов
  if txb.aaa.sta = "C" then do:
     find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' and
           txb.sub-cod.rdt = 10/18/2012 no-lock no-error.
     if not avail txb.sub-cod then next.
  end.

  if txb.aaa.sta <> "C" and txb.aaa.regdt <> 10/18/2012 then next.
  if txb.aaa.aaa <> "KZ30470472203A188015" then next.
  */

 /*убрать после 02/11/2009 if (length(txb.aaa.aaa) > 9) then next.*/

 if (length(txb.aaa.aaa) < 20) then next.

 find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
 if not avail txb.cif then next.

 if txb.aaa.sta = 'C' then v-opertype = '2'. else v-opertype = '1'.

 run savelog("MT998_400", "112. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo + " " + txb.cif.doctype).
 /*****блок обработки клиентов ФЛ имеющих и имевших ИП*/
 if lookup(txb.aaa.lgr,v-listfl) > 0 and txb.cif.geo = "021"  then do:  /*счет для резидента ФЛ?*/
     if lookup(txb.cif.doctype,"04,05") = 0 then do:
         run savelog("MT998_400", "115. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
         /*являится ли клиент ИП или адвокатом или нотариусом или ЧСИ*/
         find first rnn where rnn.bin = txb.cif.bin and (rnn.info[2] = "1" or lookup(rnn.info[4],"1,2,3,4") > 0) no-lock no-error.

         if v-opertype = "1" then do:
            if not avail rnn then next.
            if avail rnn and rnn.datdoki <> ? then next.
         end.

         /*если по счету производитоль уведомление об открытии счета, то уведомление о закрытии необходимо отправить, вне зависимости является теперь клиент ИП или адвокатом или нотариусом*/
         if v-opertype = "2" then do:
             find first acclet-detail where acclet-detail.acc = txb.aaa.aaa and acclet-detail.opertype = "1" no-lock no-error.
             if not avail acclet-detail then do:
                if not avail rnn then next.
                if avail rnn and rnn.datdoki <> ? then next.
             end.
         end.
         run savelog("MT998_400", "133. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
     end. else do:
        run savelog("MT998_400", "150. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo + " " + txb.cif.doctype).
        if txb.cif.type = "p" and txb.cif.geo = '021' and lookup(txb.aaa.lgr,"138,139,140,202,204,208,222,249,246") = 0 then next.
     end.
 end. else do: /*иначе оставляем проверки, которые существовали ранее*/
    run savelog("MT998_400", "135. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo + " " + txb.cif.doctype).
    if txb.cif.type = "p" and txb.cif.geo <> '022' then next.
    if txb.cif.type = "p" and txb.cif.geo = '022' and v-opertype = '2' and txb.aaa.regdt <= 01.19.2009 then next.
    run savelog("MT998_400", "138. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
    if txb.cif.type = "p" and txb.cif.geo = '022' and lookup(txb.aaa.lgr,"202,204,222,208,249,246,247,248,138,139,140") = 0 then next.
    run savelog("MT998_400", "140. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
 end.
 /***************************************************/



 run savelog("MT998_400", "144. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo + " " + txb.cif.doctype).
 if txb.aaa.lgr begins "4" then v-acctype = '05'. else v-acctype = '20'.
 if txb.aaa.sta = "C" then do:
   find txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock.
   v-dt = txb.sub-cod.rdt.
   if txb.sub-cod.rdt = txb.aaa.regdt then do:
      find first txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.jdt = txb.sub-cod.rdt no-lock no-error.
          if avail txb.jl then do:
             run savelog("MT998_400", "152. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
             create t-acc.
             assign t-acc.jame = txb.cif.jame
                    t-acc.acc = txb.aaa.aaa
                    t-acc.acctype = v-acctype
                    t-acc.opertype = "1"
                    t-acc.rnn = txb.cif.jss
                    t-acc.bin = txb.cif.bin
                    t-acc.dt = txb.aaa.regdt.
                    t-acc.bik = trim(txb.sysc.chval).
          end. else next.
   end.
 end. else v-dt = txb.aaa.regdt.
 run savelog("MT998_400", "165. " + txb.aaa.aaa + " " + txb.aaa.lgr + " " + txb.cif.geo).
 create t-acc.
 assign t-acc.jame = txb.cif.jame
        t-acc.acc = txb.aaa.aaa
        t-acc.bik = trim(txb.sysc.chval)
        t-acc.acctype = v-acctype
        t-acc.opertype = v-opertype
        t-acc.rnn = txb.cif.jss
        t-acc.bin = txb.cif.bin
        t-acc.dt = v-dt.

end.
