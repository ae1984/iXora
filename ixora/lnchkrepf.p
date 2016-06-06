/* chk_clnd.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
 * RUN
       Способ вызова программы, описание параметров, примеры вызова
 * CALLER
       Список процедур, вызывающих этот файл
 * SCRIPT
       Список скриптов, вызывающих этот файл
 * INHERIT
       Список вызываемых процедур
 * MENU
       Перечень пунктов Меню Прагмы
 * AUTHOR
       01/04/2011 kapar
 * BASES
	TXB COMM
 * CHANGES
       08/12/2004 madiyar - исправил ошибку, возникающую при инициализации дат
       05/01/2005 madiyar - добавил отчет по проведенным проверкам
       05/05/2005 madiyar - из отчетов по просроченным и актуальным проверкам исключил погашенные кредиты
       31/05/2005 madiyar - подправил инициализацию дат
       23/12/2005 Natalya D. - добавила столбцы для пунктов: 1,2 - "Дата проверки целевого использования кредита по графику";
                                                                   "Исполнитель"
                                                               3 - "Дата проверки целевого использования кредита по графику";
                                                                   "Дата проведения проверки";
                                                                   "Исполнитель"
       28/12/2005 Natalya D. - добавила столбцы "Дата окончания действия страховки" и "Исполнитель".
                             - реализовала разбивку в отчёте на юр.лиц и физ.лиц.
       16/05/2006 Natalya D. - добавила столбцы "Комиссия за неиспольз. кред.линию", "Комиссия за обсл-е кредита", "Комиссия за предост-е бизнес-кредитов"
       12/09/2006 Natalya D. - добавлены столбцы "Дата окон-ия срока дейст-я депозита", "Исполнитель".
                               добавлена проверка на отсутствие остатков на ур.1,2,4,5,7,9,13,14,16,30.
       09/10/2006 madiyar - списанные кредиты не выводим;
                            в просроченных и актуальных проверках в случае изменения отв.менеджера, меняем логин на актуальный;
                            no-undo
       23/10/2009 madiyar - по всем кредитам, фин-хоз и для физ. лиц тоже
       26/01/2011 madiyar - убрал три проверки, добавил проверку решения КК, расширенный мониторинг
       14/02/2011 madiyar - изменил формат отчета
       13/04/2011 madiyar - исправил проверку признака "clsarep" по КЛ
       25/10/2010 kapar - исправил просроченное решение КК
       24/01/2011 kapar - ТЗ 1265
       05.11.2012 evseev - ТЗ-1293
       25/02/2013 sayat(id01143) - ТЗ 1696 от 04/02/2013 вывод в отчет отвественного по обеспечению
       14/06/2013 galina - ТЗ1552
       17/06/2013 galina - добавила алиас COMM
       19/06/2013 Sayat(id01143) - ТЗ 1908 от 19/06/2013 откорректирован отбор актуальных кредитных линий (првоведенные проверки)
       19/06/2013 yerganat - tz1804, добавил заполнение "Заметки ДМО" в temp таблицу
       18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониториг залогов - переоценка"
       02/09/2013 galina - ТЗ1918 перекомпиляция
       17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr

*/

def input parameter p-bank as char no-undo.
def input parameter v-sel as char no-undo.
def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.

def shared var g-today  as date.
def var dt2-1 as date no-undo.
/*dt2-1 = dt2.
if dt2 > g-today then*/ dt2-1 = g-today.


def shared temp-table lnpr no-undo
  field cif         like txb.lon.cif
  field name        as   char
  field sts         like txb.cif.type  /*P - физ.лица, B - юр.лица*/
  field lon         like txb.lon.lon
  field pdt_finhoz  as   date init ?
  field pwho_finhoz as   char
  field pdt_zalog   as   date init ?
  field pwho_zalog  as   char
  field edt_finhoz  as   date init ?
  field ewho_finhoz as   char
  field edt_zalog   as   date init ?
  field ewho_zalog  as   char
  field pdt_purp    as   date init ?
  field pwho_purp   as   char
  field edt_purp    as   date init ?
  field ewho_purp   as   char
  field pdt_insu    as   date init ?
  field pwho_insu   as   char
  field edt_insu    as   date init ?
  field ewho_insu   as   char
  field pb_name     as   char

  /*
  field pdt_crln    as   date init ?
  field pwho_crln   as   char
  field edt_crln    as   date init ?
  field ewho_crln   as   char
  field pdt_crsr    as   date init ?
  field pwho_crsr   as   char
  field edt_crsr    as   date init ?
  field ewho_crsr   as   char
  field pdt_crbs    as   date init ?
  field pwho_crbs   as   char
  field edt_crbs    as   date init ?
  field ewho_crbs   as   char
  */
  field pdt_dep     as   date init ?
  field pwho_dep    as   char
  field edt_dep     as   date init ?
  field ewho_dep    as   char
  field pdt_kk      as   date init ?
  field pwho_kk     as   char
  field edt_kk      as   date init ?
  field ewho_kk     as   char
  field kk_rem      as   char
  field pdt_dmo     as   date init ?
  field pwho_dmo    as   char
  field edt_dmo     as   date init ?
  field ewho_dmo    as   char
  field dmo_rem     as   char
  field pdt_extmon      as   date init ?
  field pwho_extmon     as   char
  field edt_extmon      as   date init ?
  field ewho_extmon     as   char
  field sum as decimal
  field sumlimkz as decimal
  field crc as char
  field mng_zalog   as   char
  field des_zalog   as   char
  field otsr_finhoz as   int
  field otsr_zalog  as   int
  field otsr_purp   as   int
  field otsr_insu   as   int
  field otsr_dep    as   int
  field otsr_kk     as   int
  field otsr_dmo    as   int
  field otsr_extmon as   int
  index ind is primary cif lon pdt_finhoz pdt_zalog edt_finhoz edt_zalog pdt_purp edt_purp pdt_insu edt_insu sts.


def shared temp-table tgaran no-undo
  field cif         like txb.garan.cif
  field name        as   char
  field sts         like txb.cif.type  /*P - физ.лица, B - юр.лица*/
  field lon         like txb.garan.garan
  field pdt_finhoz  as   date init ?
  field pwho_finhoz as   char
  field pdt_zalog   as   date init ?
  field pwho_zalog  as   char
  field edt_finhoz  as   date init ?
  field ewho_finhoz as   char
  field edt_zalog   as   date init ?
  field ewho_zalog  as   char
  field pdt_purp    as   date init ?
  field pwho_purp   as   char
  field edt_purp    as   date init ?
  field ewho_purp   as   char
  field pdt_insu    as   date init ?
  field pwho_insu   as   char
  field edt_insu    as   date init ?
  field ewho_insu   as   char
  field pb_name     as   char
  field pdt_dep     as   date init ?
  field pwho_dep    as   char
  field edt_dep     as   date init ?
  field ewho_dep    as   char
  field pdt_kk      as   date init ?
  field pwho_kk     as   char
  field edt_kk      as   date init ?
  field ewho_kk     as   char
  field kk_rem      as   char
  field pdt_extmon      as   date init ?
  field pwho_extmon     as   char
  field edt_extmon      as   date init ?
  field ewho_extmon     as   char
  field sumlimkz as decimal
  field crc as char
  field mng_zalog   as   char
  field des_zalog   as   char
  field otsr_finhoz as   int
  field otsr_zalog  as   int
  field otsr_purp   as   int
  field otsr_insu   as   int
  field otsr_dep    as   int
  field otsr_kk     as   int
  field otsr_dmo    as   int
  field otsr_extmon as   int
  index ind is primary cif lon pdt_finhoz pdt_zalog edt_finhoz edt_zalog pdt_purp edt_purp pdt_insu edt_insu sts.



def var b-dt as date no-undo.
def var usrnm as char no-undo.
def var bilance as deci no-undo.
def var bilance1 as deci no-undo.
def var bilance2 as deci no-undo.
def var cl-voz as deci no-undo.
def var cl-nevoz as deci no-undo.
def var dam1-cam1 as deci no-undo.
def stream rep.


function valOfc returns char (input v-ofc as char).
  def var res as char no-undo.
  find first txb.ofc where txb.ofc.ofc = v-ofc no-lock no-error.
  if available txb.ofc then do:
    res = string(v-ofc) + '-' + txb.ofc.name.
    return res.
  end.
  else do:
    res = string(v-ofc).
    return res.
  end.
end function.



def stream repdtl.
output stream repdtl to repdtl.csv.

def buffer b-lon for txb.lon.
def buffer b-lnmoncln for txb.lnmoncln.
def var crowid as rowid.

  case v-sel:
    when '1' then do:

      for each txb.lon no-lock:
        if txb.lon.gua = 'CL' then do:
            if txb.lon.duedt < g-today then next.
            find first txb.sub-cod where txb.sub-cod.acc=txb.lon.lon and txb.sub-cod.d-cod = 'clsarep' and txb.sub-cod.ccode = '01' no-lock no-error.
            if available txb.sub-cod then next.
        end.
        else do:
            if txb.lon.opnamt = 0 then next.
            run lonbalcrc_txb('lon',lon.lon,g-today,"1,2,4,7,9",yes,lon.crc,output bilance1).
            run lonbalcrc_txb('lon',lon.lon,g-today,"5,16",yes,1,output bilance2).
            if bilance1 <= 0 and bilance2 <= 0 then next.
        end.

        find txb.cif where cif.cif = txb.lon.cif no-lock no-error.
        find first txb.loncon where loncon.lon = txb.lon.lon no-lock no-error.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             /*run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'1',yes,txb.lon.crc,output dam1-cam1).
             run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'15',yes,txb.lon.crc,output cl-voz).
             cl-voz = - cl-voz.
             run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'35',yes,txb.lon.crc,output cl-nevoz).
             cl-nevoz = - cl-nevoz.*/
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then do:
                lnpr.crc = txb.crc.code.
                /*lnpr.sumlimkz = (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].*/
             end.
             /*if txb.lon.crc = 1 then lnpr.sumlimkz = dam1-cam1 + cl-voz + cl-nevoz.*/
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                /*run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1',yes,b-lon.crc,output dam1-cam1).
                run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                cl-voz = - cl-voz.
                run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                cl-nevoz = - cl-nevoz.*/
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then do:
                   lnpr.crc = txb.crc.code.
                   /*lnpr.sumlimkz = (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].*/
                end.
                /*if b-lon.crc = 1 then lnpr.sumlimkz = dam1-cam1 + cl-voz + cl-nevoz.*/
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                /*
                run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'1',yes,txb.lon.crc,output dam1-cam1).
                run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'15',yes,txb.lon.crc,output cl-voz).
                cl-voz = - cl-voz.
                run lonbalcrc_txb('lon',txb.lon.lon,dt2-1,'35',yes,txb.lon.crc,output cl-nevoz).
                cl-nevoz = - cl-nevoz.*/
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then do:
                   lnpr.crc = txb.crc.code.
                   /*lnpr.sumlimkz = (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].*/
                end.
                /*if txb.lon.crc = 1 then lnpr.sumlimkz = dam1-cam1 + cl-voz + cl-nevoz.*/
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.


          lnpr.cif = txb.lon.cif.
          lnpr.pb_name = p-bank.
          if avail cif
          then do:
             lnpr.name = txb.cif.name.
             lnpr.sts = txb.cif.type.
          end.
          else lnpr.name = '--не найден--'.
          lnpr.lon = txb.lon.lon.
          lnpr.pdt_finhoz = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_zalog = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_zalog = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
            if trim(txb.loncon.obes-pier) <> '' then lnpr.mng_zalog = valOfc(trim(txb.loncon.obes-pier)).
          end.
          find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then lnpr.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else lnpr.des_zalog = ''.
          lnpr.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_purp = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_purp = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_purp = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_insu = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_insu = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_insu = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dep = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dep = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_dep = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        /*
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        */
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt < g-today
                                /*and txb.lnmoncln.pdt > b-dt*/ and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_kk = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_kk = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_kk = valOfc(txb.lnmoncln.pwho).
          lnpr.kk_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'remarkdmo' and txb.lnmoncln.pdt < g-today
                                /*and txb.lnmoncln.pdt > b-dt*/ and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dmo = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dmo = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_dmo = valOfc(txb.lnmoncln.pwho).
          lnpr.dmo_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_dmo = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_extmon = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_extmon = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end. /* for each txb.lon */

    end. /* when '1' */
    when '2' then do:

      for each txb.lon no-lock:

        if txb.lon.gua = 'CL' then do:
            if txb.lon.duedt < g-today then do:
             put stream repdtl unformatted 'CL' ";" txb.lon.cif ";" txb.lon.lon ";" 'lon.duedt < g-today' skip.
             next.
            end.
            find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'clsarep' and txb.sub-cod.ccode = '01' no-lock no-error.
            if available txb.sub-cod then do:
             put stream repdtl unformatted 'CL' ";" txb.lon.cif ";" txb.lon.lon ";" 'кредитная линия CL, счет закрыт' skip.
             next.
            end.
        end.
        else do:
            if txb.lon.opnamt = 0 then do:
             put stream repdtl unformatted 'CL' ";" txb.lon.cif ";" txb.lon.lon ";" 'lon.opnamt = 0' skip.
             next.
            end.

            run lonbalcrc_txb('lon',lon.lon,g-today,"1,2,4,7,9",yes,lon.crc,output bilance1).
            run lonbalcrc_txb('lon',lon.lon,g-today,"5,16",yes,1,output bilance2).
            if bilance1 <= 0 and bilance2 <= 0 then do:
             put stream repdtl unformatted 'CL' ";" txb.lon.cif ";" txb.lon.lon ";" 'баланс <= 0 ' skip.
             next.
            end.
        end.

        find txb.cif where cif.cif = txb.lon.cif no-lock no-error.
        find first txb.loncon where loncon.lon = txb.lon.lon no-lock no-error.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon no-lock:
             put stream repdtl unformatted txb.lon.cif ";" txb.lon.lon ";" txb.lnmoncln.code ";" txb.lnmoncln.pdt  ";"  txb.lnmoncln.edt skip.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
          lnpr.cif = txb.lon.cif.
          lnpr.pb_name = p-bank.
          if avail cif
          then do:
             lnpr.name = txb.cif.name.
             lnpr.sts = txb.cif.type.
          end.
          else lnpr.name = '--не найден--'.
          lnpr.lon = txb.lon.lon.
          lnpr.pdt_finhoz = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_zalog = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_zalog = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
            if trim(txb.loncon.obes-pier) <> '' then lnpr.mng_zalog = valOfc(trim(txb.loncon.obes-pier)).
          end.
          find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then lnpr.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else lnpr.des_zalog = ''.
          lnpr.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_purp = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_purp = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_purp = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_insu = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_insu = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_insu = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dep = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dep = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_dep = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        /*
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        */
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                /*and txb.lnmoncln.pdt > b-dt*/ and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_kk = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_kk = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_kk = valOfc(txb.lnmoncln.pwho).
          lnpr.kk_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'remarkdmo' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                /*and txb.lnmoncln.pdt > b-dt*/ and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dmo = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dmo = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_dmo = valOfc(txb.lnmoncln.pwho).
          lnpr.dmo_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_dmo = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_extmon = ? no-error.
          if not avail lnpr then do:
            create lnpr.
            if txb.lon.gua = 'CL' then do:
               lnpr.sum = txb.lon.opnamt.
               find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
               if avail txb.crc then lnpr.crc = txb.crc.code.
            end. else if txb.lon.gua = 'LO' then do:
               find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
               if avail b-lon and txb.lon.clmain <> ""  then do:
                  lnpr.sum = b-lon.opnamt.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end. else do:
                  lnpr.sum = txb.lon.opnamt.
                  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                  if avail txb.crc then lnpr.crc = txb.crc.code.
               end.
            end.
              lnpr.sumlimkz = 0.
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
                  cl-voz = - cl-voz.
                  run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
                  cl-nevoz = - cl-nevoz.
                  find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                  if avail txb.crc and b-lon.crc <> 1 then do:
                     lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
                  end.
                  if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
              end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_extmon = txb.lnmoncln.pdt.
          if avail txb.loncon then do:
            if txb.loncon.pase-pier <> txb.lnmoncln.pwho then do:
              find first b-lnmoncln where rowid(b-lnmoncln) = rowid(lnmoncln) exclusive-lock no-error.
              if avail b-lnmoncln then do:
                b-lnmoncln.pwho = valOfc(txb.loncon.pase-pier).
                find current b-lnmoncln no-lock.
              end.
            end.
          end.
          lnpr.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          lnpr.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end.

    end.
    when '3' then do:

      for each txb.lon no-lock:

        if txb.lon.gua = 'CL' then do:
            if txb.lon.duedt < g-today then next.
            find first txb.sub-cod where txb.sub-cod.acc=txb.lon.lon and txb.sub-cod.d-cod='clsarep' and txb.sub-cod.ccode='01' no-lock no-error.
            if /*not*/ available txb.sub-cod then next.
        end.
        else do:
            if txb.lon.opnamt = 0 then next.
            run lonbalcrc_txb('lon',lon.lon,g-today,"1,2,4,7,9",yes,lon.crc,output bilance1).
            run lonbalcrc_txb('lon',lon.lon,g-today,"5,16",yes,1,output bilance2).
            if bilance1 <= 0 and bilance2 <= 0 then next.
        end.

        find txb.cif where cif.cif = txb.lon.cif no-lock no-error.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
          lnpr.cif = txb.lon.cif.
          lnpr.pb_name = p-bank.
          if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
          lnpr.lon = txb.lon.lon.
          lnpr.pdt_finhoz = txb.lnmoncln.pdt.
          lnpr.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_finhoz = txb.lnmoncln.edt.
          lnpr.ewho_finhoz = valOfc(lnmoncln.ewho).
          lnpr.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_zalog = ? and lnpr.edt_zalog = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_zalog = txb.lnmoncln.pdt.
          lnpr.pwho_zalog = valOfc(txb.lnmoncln.pwho).

          find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
          if trim(txb.loncon.obes-pier) <> '' then lnpr.mng_zalog = valOfc(trim(txb.loncon.obes-pier)).
          find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then lnpr.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else lnpr.des_zalog = ''.
          lnpr.edt_zalog = txb.lnmoncln.edt.
          lnpr.ewho_zalog = valOfc(lnmoncln.ewho).
          lnpr.otsr_zalog = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_purp = ? and lnpr.edt_purp = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_purp = txb.lnmoncln.pdt.
          lnpr.pwho_purp = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_purp = txb.lnmoncln.edt.
          lnpr.ewho_purp = valOfc(lnmoncln.ewho).
          lnpr.otsr_purp = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_insu = ? and lnpr.edt_insu = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_insu = txb.lnmoncln.pdt.
          lnpr.pwho_insu = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_insu = txb.lnmoncln.edt.
          lnpr.ewho_insu = valOfc(lnmoncln.ewho).
          lnpr.otsr_insu = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dep = ? and lnpr.edt_dep = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dep = txb.lnmoncln.pdt.
          lnpr.pwho_dep = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_dep = txb.lnmoncln.edt.
          lnpr.ewho_dep = valOfc(lnmoncln.ewho).
          lnpr.otsr_dep = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_kk = ? and lnpr.edt_kk = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_kk = txb.lnmoncln.pdt.
          lnpr.pwho_kk = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_kk = txb.lnmoncln.edt.
          lnpr.ewho_kk = valOfc(lnmoncln.ewho).
          lnpr.kk_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_kk = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'remarkdmo' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_dmo = ? and lnpr.edt_dmo = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_dmo = txb.lnmoncln.pdt.
          lnpr.pwho_dmo = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_dmo = txb.lnmoncln.edt.
          lnpr.ewho_dmo = valOfc(lnmoncln.ewho).
          lnpr.dmo_rem = txb.lnmoncln.res-ch[1].
          lnpr.otsr_dmo = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first lnpr where lnpr.cif = txb.lon.cif and lnpr.lon = txb.lon.lon and lnpr.pdt_extmon = ? and lnpr.edt_extmon = ? no-error.
          if not avail lnpr then do:
            create lnpr.
          if txb.lon.gua = 'CL' then do:
             lnpr.sum = txb.lon.opnamt.
             find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
             if avail txb.crc then lnpr.crc = txb.crc.code.
          end. else if txb.lon.gua = 'LO' then do:
             find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
             if avail b-lon and txb.lon.clmain <> ""  then do:
                lnpr.sum = b-lon.opnamt.
                find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end. else do:
                lnpr.sum = txb.lon.opnamt.
                find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                if avail txb.crc then lnpr.crc = txb.crc.code.
             end.
          end.
          lnpr.sumlimkz = 0.
          for each b-lon where b-lon.cif = txb.lon.cif no-lock:
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'1,7',yes,b-lon.crc,output dam1-cam1).
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'15',yes,b-lon.crc,output cl-voz).
              cl-voz = - cl-voz.
              run lonbalcrc_txb('lon',b-lon.lon,dt2-1,'35',yes,b-lon.crc,output cl-nevoz).
              cl-nevoz = - cl-nevoz.
              find first txb.crc where txb.crc.crc = b-lon.crc no-lock no-error.
              if avail txb.crc and b-lon.crc <> 1 then do:
                 lnpr.sumlimkz = lnpr.sumlimkz + (dam1-cam1 + cl-voz + cl-nevoz) * crc.rate[1].
              end.
              if b-lon.crc = 1 then lnpr.sumlimkz = lnpr.sumlimkz + dam1-cam1 + cl-voz + cl-nevoz.
          end.
            lnpr.cif = txb.lon.cif.
            lnpr.pb_name = p-bank.
            if avail cif
            then do:
               lnpr.name = txb.cif.name.
               lnpr.sts = txb.cif.type.
            end.
            else lnpr.name = '--не найден--'.
            lnpr.lon = txb.lon.lon.
          end.
          lnpr.pdt_extmon = txb.lnmoncln.pdt.
          lnpr.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          lnpr.edt_extmon = txb.lnmoncln.edt.
          lnpr.ewho_extmon = valOfc(lnmoncln.ewho).
          lnpr.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end.

    end.
  end case.

output stream repdtl close.
/*
unix silent cptwin repdtl.csv excel.
*/

/*********galina гарантии************/
  case v-sel:
    when '1' then do:
      for each txb.garan no-lock:
        if txb.garan.dtto < g-today then next.

        find txb.cif where txb.cif.cif = txb.garan.cif no-lock no-error.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
              create tgaran.
              assign tgaran.cif = txb.garan.cif
                     tgaran.pb_name = p-bank.


              find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
              if avail txb.crc then  do:
                    tgaran.crc = txb.crc.code.
                    if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                    else tgaran.sumlimkz = txb.garan.sumtreb.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
              assign tgaran.lon = txb.garan.garnum
                     tgaran.pdt_finhoz = txb.lnmoncln.pdt.
                     tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
              tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_zalog = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.
          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = txb.garan.garan and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_purp = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.
          end.

          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_insu = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.
          end.

          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_dep = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.
          end.

          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt < g-today
                                 and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_kk = ? no-error.

          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_extmon = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end. /* for each txb.lon */

    end. /* when '1' */
    when '2' then do:

      for each txb.garan no-lock:

        if txb.garan.dtto < g-today then next.
        find txb.cif where cif.cif = txb.garan.cif no-lock no-error.


        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          create tgaran.
          assign tgaran.cif = txb.garan.cif
                 tgaran.pb_name = p-bank.

           find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
           if avail txb.crc then  do:
                tgaran.crc = txb.crc.code.
                if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                else tgaran.sumlimkz = txb.garan.sumtreb.
           end.

           if avail txb.cif then assign tgaran.name = txb.cif.name
                                        tgaran.sts = txb.cif.type.
           else tgaran.name = '--не найден--'.
                tgaran.lon = txb.garan.garnum.

                tgaran.pdt_finhoz = txb.lnmoncln.pdt.
                tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
                tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_zalog = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = txb.garan.garan and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_purp = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_insu = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_dep = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_kk = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:

          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_extmon = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.


          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.
      end.
    end.
    when '3' then do:

      for each txb.garan no-lock:
        if txb.garan.dtto < g-today then next.

        find txb.cif where cif.cif = txb.garan.cif no-lock no-error.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          create tgaran.
          assign tgaran.cif = txb.garan.cif
                 tgaran.pb_name = p-bank.


          find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
          if avail txb.crc then  do:
                tgaran.crc = txb.crc.code.
                if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                 else tgaran.sumlimkz = txb.garan.sumtreb.
           end.

           if avail txb.cif then assign tgaran.name = txb.cif.name
                                        tgaran.sts = txb.cif.type.
           else tgaran.name = '--не найден--'.
                tgaran.lon = txb.garan.garnum.

           tgaran.lon = txb.garan.garnum.
           tgaran.pdt_finhoz = txb.lnmoncln.pdt.
           tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
           tgaran.edt_finhoz = txb.lnmoncln.edt.
           tgaran.ewho_finhoz = valOfc(lnmoncln.ewho).
           tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.
        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_zalog = ? and tgaran.edt_zalog = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = txb.garan.garan and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.edt_zalog = txb.lnmoncln.edt.
          tgaran.ewho_zalog = valOfc(lnmoncln.ewho).
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_purp = ? and tgaran.edt_purp = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_purp = txb.lnmoncln.edt.
          tgaran.ewho_purp = valOfc(lnmoncln.ewho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_insu = ? and tgaran.edt_insu = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.
          end.
          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_insu = txb.lnmoncln.edt.
          tgaran.ewho_insu = valOfc(lnmoncln.ewho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_dep = ? and tgaran.edt_dep = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_dep = txb.lnmoncln.edt.
          tgaran.ewho_dep = valOfc(lnmoncln.ewho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_kk = ? and tgaran.edt_kk = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_kk = txb.lnmoncln.edt.
          tgaran.ewho_kk = valOfc(lnmoncln.ewho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = txb.garan.garan and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = txb.garan.cif and tgaran.lon = txb.garan.garnum and tgaran.pdt_extmon = ? and tgaran.edt_extmon = ? no-error.
          if not avail tgaran then do:
                  create tgaran.
                  assign tgaran.cif = txb.garan.cif
                         tgaran.pb_name = p-bank.


                  find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        if txb.garan.crc <> 1 then  tgaran.sumlimkz = txb.garan.sumtreb * txb.crc.rate[1].
                        else tgaran.sumlimkz = txb.garan.sumtreb.
                  end.

                  if avail txb.cif then assign tgaran.name = txb.cif.name
                                               tgaran.sts = txb.cif.type.
                  else tgaran.name = '--не найден--'.
                       tgaran.lon = txb.garan.garnum.

          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_extmon = txb.lnmoncln.edt.
          tgaran.ewho_extmon = valOfc(lnmoncln.ewho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end.

    end.
  end case.
/*************************************/

def var v-crc like txb.crc.crc.
def var  v-bankcode as char.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
else v-bankcode = trim(txb.sysc.chval).

  case v-sel:
    when '1' then do:
      for each lclimit where lclimit.bank = v-bankcode no-lock:
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'DtExp' no-lock no-error.
        if avail lclimith and lclimith.value1 <> ? and date(lclimith.value1) < g-today then next.

        find txb.cif where txb.cif.cif = lclimit.cif no-lock no-error.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
              assign tgaran.lon = string(lclimit.number)
                     tgaran.pdt_finhoz = txb.lnmoncln.pdt.
                     tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
              tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_zalog = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_purp = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_insu = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.

          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_dep = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.

          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt < g-today
                                 and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_kk = ? no-error.

          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt < g-today
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_extmon = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end. /* for each txb.lon */

    end. /* when '1' */
    when '2' then do:

      for each lclimit where lclimit.bank = v-bankcode no-lock:
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'DtExp' no-lock no-error.
        if avail lclimith and lclimith.value1 <> ? and date(lclimith.value1) < g-today then next.

        find txb.cif where cif.cif = lclimit.cif no-lock no-error.


        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:

              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).



                tgaran.pdt_finhoz = txb.lnmoncln.pdt.
                tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
                tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_zalog = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_purp = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'insur' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_insu = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_dep = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.edt = ? no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_kk = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        b-dt = 01/01/1900.
        find last txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then b-dt = txb.lnmoncln.pdt.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.pdt >= dt1 and txb.lnmoncln.pdt <= dt2
                                and txb.lnmoncln.pdt > b-dt and txb.lnmoncln.edt = ? no-lock:

          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_extmon = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.
      end.
    end.
    when '3' then do:

      for each lclimit where lclimit.bank = v-bankcode no-lock:
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'DtExp' no-lock no-error.
        if avail lclimith and lclimith.value1 <> ? and date(lclimith.value1) < g-today then next.
        find txb.cif where cif.cif = lclimit.cif no-lock no-error.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'fin-hoz' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:

              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).


               tgaran.lon = string(lclimit.number).
               tgaran.pdt_finhoz = txb.lnmoncln.pdt.
               tgaran.pwho_finhoz = valOfc(txb.lnmoncln.pwho).
               tgaran.edt_finhoz = txb.lnmoncln.edt.
               tgaran.ewho_finhoz = valOfc(lnmoncln.ewho).
               tgaran.otsr_finhoz = txb.lnmoncln.otsr.
        end.
        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'zalog' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_zalog = ? and tgaran.edt_zalog = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_zalog = txb.lnmoncln.pdt.
          tgaran.pwho_zalog = valOfc(txb.lnmoncln.pwho).
          find first txb.lonsec1 where txb.lonsec1.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lonsec1.ln = integer(txb.lnmoncln.zalnum) no-lock no-error.
          if avail txb.lonsec1 then tgaran.des_zalog = string(txb.lonsec1.ln) + '. ' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
          else tgaran.des_zalog = ''.
          tgaran.edt_zalog = txb.lnmoncln.edt.
          tgaran.ewho_zalog = valOfc(lnmoncln.ewho).
          tgaran.otsr_zalog = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'purpose' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_purp = ? and tgaran.edt_purp = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_purp = txb.lnmoncln.pdt.
          tgaran.pwho_purp = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_purp = txb.lnmoncln.edt.
          tgaran.ewho_purp = valOfc(lnmoncln.ewho).
          tgaran.otsr_purp = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_insu = ? and tgaran.edt_insu = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_insu = txb.lnmoncln.pdt.
          tgaran.pwho_insu = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_insu = txb.lnmoncln.edt.
          tgaran.ewho_insu = valOfc(lnmoncln.ewho).
          tgaran.otsr_insu = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'deposit' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_dep = ? and tgaran.edt_dep = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_dep = txb.lnmoncln.pdt.
          tgaran.pwho_dep = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_dep = txb.lnmoncln.edt.
          tgaran.ewho_dep = valOfc(lnmoncln.ewho).
          tgaran.otsr_dep = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'kkres' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_kk = ? and tgaran.edt_kk = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_kk = txb.lnmoncln.pdt.
          tgaran.pwho_kk = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_kk = txb.lnmoncln.edt.
          tgaran.ewho_kk = valOfc(lnmoncln.ewho).
          tgaran.kk_rem = txb.lnmoncln.res-ch[1].
          tgaran.otsr_kk = txb.lnmoncln.otsr.
        end.

        for each txb.lnmoncln where txb.lnmoncln.lon = lclimit.cif + 'LCLIM' + trim(string(lclimit.number,'>>99')) and txb.lnmoncln.code = 'extmon' and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock:
          find first tgaran where tgaran.cif = lclimit.cif and tgaran.lon = string(lclimit.number) and tgaran.pdt_extmon = ? and tgaran.edt_extmon = ? no-error.
          if not avail tgaran then do:
              create tgaran.
              assign tgaran.cif = lclimit.cif
                     tgaran.pb_name = p-bank.
              v-crc = 0.
              find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:

                  v-crc = int(trim(lclimith.value1)).

                  find first txb.crc where txb.crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                  if avail txb.crc then  do:
                        tgaran.crc = txb.crc.code.
                        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Amount' no-lock no-error.
                        if avail lclimith and trim(lclimith.value1) <> '' then do:
                            if v-crc <> 1 then tgaran.sumlimkz = deci(lclimith.value1) * txb.crc.rate[1].
                            else tgaran.sumlimkz = deci(lclimith.value1).
                        end.
                  end.
              end.

              if avail txb.cif then assign tgaran.name = txb.cif.name
                                           tgaran.sts = txb.cif.type.
              else tgaran.name = '--не найден--'.
                   tgaran.lon = string(lclimit.number).
          end.
          tgaran.pdt_extmon = txb.lnmoncln.pdt.
          tgaran.pwho_extmon = valOfc(txb.lnmoncln.pwho).
          tgaran.edt_extmon = txb.lnmoncln.edt.
          tgaran.ewho_extmon = valOfc(lnmoncln.ewho).
          tgaran.otsr_extmon = txb.lnmoncln.otsr.
        end.

      end.

    end.
  end case.




























