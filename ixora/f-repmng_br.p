/* f-repmng_br.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Управленческая отчетность
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18
 * AUTHOR
        13/01/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        11/03/2011 k.gitalov расчет по факту, период месяц
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
        13.08.2013 damir - Внедрено Т.З. № 1182,1258,1257,1650. lonrp18 собирает данные ЦО и Консолид (было только TXB00).
*/

{mainhead.i}
{nbankBik.i}

def new shared temp-table t-period no-undo
  field pid as integer
  field dtb as date
  field dte as date
  index idx is primary dtb.

def new shared temp-table t-krit no-undo
  field kid as integer
  field kcode as char
  field bold_code as log
  field color_code as log
  field des_en as char
  field des_ru as char
  field level as integer
  index idx is primary kid
  index idx2 kcode.

def new shared temp-table t-kritval no-undo
  field bank as char
  field kid as integer
  field pid as integer
  field sum as deci
  index idx is primary bank kid pid.

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var v-dt as date no-undo.
def var i as integer.
def var v-result as char no-undo.
def var repname as char no-undo.

{dates.i}


if month(g-today) = 1 then dt1 = date( 12 , 1 , year(g-today) - 1 ).
else dt1 = date( month(g-today) - 1 , 1 , year(g-today) ).
dt2 = date( month(dt1) , DaysInMonth(dt1) , year(dt1) ).
displ dt1 label " С " format "99/99/9999" validate(day(dt1) = 1 and dt1 < g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate(LastDay(dt2) and dt2 < g-today and dt1 < dt2, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

v-dt = dt1.
i = 0.
repeat:
    if v-dt < dt2 then do:
        i = i + 1.
        create t-period.
               t-period.pid = i.
               t-period.dtb = v-dt.
               t-period.dte = v-dt + DaysInMonth(v-dt) - 1.
    end.
    else leave.
    v-dt = v-dt + DaysInMonth(v-dt).
end.


/*
dt2 = g-today - (weekday(g-today) - 1).
dt1 = dt2 - 6.

displ dt1 label " С " format "99/99/9999" validate(weekday(dt1) = 2 and dt1 < g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate(weekday(dt2) = 1 and dt2 < g-today and dt1 < dt2, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

v-dt = dt1.
i = 0.
repeat:
    if v-dt < dt2 then do:
        i = i + 1.
        create t-period.
        assign t-period.pid = i
               t-period.dtb = v-dt
               t-period.dte = v-dt + 6.
    end.
    else leave.
    v-dt = v-dt + 7.
end.
*/

{repmng_br.i}


def var s-ourbank as char.
s-ourbank = "consolid".

function getKID returns integer (input p-kcode as char).
    find first t-krit where t-krit.kcode = p-kcode no-lock no-error.
    if avail t-krit then return t-krit.kid.
    else return 0.
end function.

function getKritVal returns deci (input p-kcode as char, input p-pid as integer).
    def var v-res as deci no-undo.
    v-res = 0.
    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-lock no-error.
        if avail t-kritval then v-res = t-kritval.sum.
    end.
    return v-res.
end function.

procedure setKritVal.
    def input parameter p-kcode as char no-undo.
    def input parameter p-pid as integer no-undo.
    def input parameter p-sum as deci no-undo.

    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-error.
        if not avail t-kritval then do:
            create t-kritval.
            assign t-kritval.bank = s-ourbank
                   t-kritval.kid = v-kid
                   t-kritval.pid = p-pid.
        end.
        t-kritval.sum = t-kritval.sum + p-sum.
    end.
end procedure.

/* Получить сохраненное ранее значение */
function getStoredKritVal returns deci (input p-bank as char, input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.

   case p-bank:
       when "txb00" then do:
          find first uprdata where uprdata.bank = "txb00" and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock no-error.
          if avail uprdata then v-res = uprdata.kvalue.
       end.
       when "txb" then do:
          for each uprdata where uprdata.bank <> "txb00" and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       when "all" then do:
          for each uprdata where uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       OTHERWISE do:
          for each uprdata where uprdata.bank = p-bank and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
   end case.

   return v-res.
end function.

/*
for each uprdata where uprdata.bank = p-bank and uprdata.kcode = "com_exp" and uprdata.dtb = data(03/01/11):
    displ uprdata
end.
*/




for each t-period no-lock:

   run setKritVal("cash",t-period.pid, getStoredKritVal("txb","cash", t-period.dtb)  ).
   run setKritVal("dueNBRK",t-period.pid, getStoredKritVal("txb00","dueNBRK", t-period.dtb)  ).
   run setKritVal("nbrkCorr",t-period.pid, getStoredKritVal("txb00","nbrkCorr", t-period.dtb)  ).
   run setKritVal("nbrkDep",t-period.pid, getStoredKritVal("txb00","nbrkDep", t-period.dtb)  ).
   run setKritVal("dueBanks",t-period.pid, getStoredKritVal("all","dueBanks", t-period.dtb)  ).
   run setKritVal("secur",t-period.pid, getStoredKritVal("txb00","secur", t-period.dtb)  ).
   run setKritVal("securTrade",t-period.pid, getStoredKritVal("txb00","securTrade", t-period.dtb)  ).
   run setKritVal("securInvest",t-period.pid, getStoredKritVal("txb00","securInvest", t-period.dtb)  ).
   run setKritVal("securREPO",t-period.pid, getStoredKritVal("txb00","securREPO", t-period.dtb)  ).

   run setKritVal("lon",t-period.pid, getStoredKritVal("all","lon", t-period.dtb)  ).
   run setKritVal("lonr",t-period.pid, getStoredKritVal("txb","lonr", t-period.dtb)  ).
   run setKritVal("lonr1",t-period.pid, getStoredKritVal("txb","lonr1", t-period.dtb)  ).
   run setKritVal("lonr2",t-period.pid, getStoredKritVal("txb","lonr2", t-period.dtb)  ).
   run setKritVal("lonr3",t-period.pid, getStoredKritVal("txb","lonr3", t-period.dtb)  ).
   run setKritVal("lonri",t-period.pid, getStoredKritVal("txb","lonri", t-period.dtb)  ).
   run setKritVal("lonro30",t-period.pid, getStoredKritVal("txb","lonro30", t-period.dtb)  ).
   run setKritVal("lonrio",t-period.pid, getStoredKritVal("txb","lonrio", t-period.dtb)  ).
   run setKritVal("lonrp",t-period.pid, getStoredKritVal("txb","lonrp", t-period.dtb)  ).
   run setKritVal("lonrp18",t-period.pid, getStoredKritVal("all","lonrp18", t-period.dtb)  ).

   run setKritVal("lons",t-period.pid, getStoredKritVal("txb","lons", t-period.dtb)  ).
   run setKritVal("lons1",t-period.pid, getStoredKritVal("txb","lons1", t-period.dtb)  ).
   run setKritVal("lons2",t-period.pid, getStoredKritVal("txb","lons2", t-period.dtb)  ).
   run setKritVal("lons3",t-period.pid, getStoredKritVal("txb","lons3", t-period.dtb)  ).
   run setKritVal("lonsi",t-period.pid, getStoredKritVal("txb","lonsi", t-period.dtb)  ).
   run setKritVal("lonso30",t-period.pid, getStoredKritVal("txb","lonso30", t-period.dtb)  ).
   run setKritVal("lonsio",t-period.pid, getStoredKritVal("txb","lonsio", t-period.dtb)  ).
   run setKritVal("lonsp",t-period.pid, getStoredKritVal("txb","lonsp", t-period.dtb)  ).
   run setKritVal("lonc",t-period.pid, getStoredKritVal("txb","lonc", t-period.dtb)  ).
   run setKritVal("lonc1",t-period.pid, getStoredKritVal("txb","lonc1", t-period.dtb)  ).
   run setKritVal("lonc2",t-period.pid, getStoredKritVal("txb","lonc2", t-period.dtb)  ).
   run setKritVal("lonc3",t-period.pid, getStoredKritVal("txb","lonc3", t-period.dtb)  ).
   run setKritVal("lonci",t-period.pid, getStoredKritVal("txb","lonci", t-period.dtb)  ).
   run setKritVal("lonco30",t-period.pid, getStoredKritVal("txb","lonco30", t-period.dtb)  ).
   run setKritVal("loncio",t-period.pid, getStoredKritVal("txb","loncio", t-period.dtb)  ).
   run setKritVal("loncp",t-period.pid, getStoredKritVal("txb","loncp", t-period.dtb)  ).

   run setKritVal("SO_lon",t-period.pid, getStoredKritVal("txb00","lon", t-period.dtb)  ).
   run setKritVal("SO_lonr1",t-period.pid, getStoredKritVal("txb00","lonr1", t-period.dtb)  ).
   run setKritVal("SO_lonr2",t-period.pid, getStoredKritVal("txb00","lonr2", t-period.dtb)  ).
   run setKritVal("SO_lonr3",t-period.pid, getStoredKritVal("txb00","lonr3", t-period.dtb)  ).
   run setKritVal("SO_lonri",t-period.pid, getStoredKritVal("txb00","lonri", t-period.dtb)  ).
   run setKritVal("SO_lonro30",t-period.pid, getStoredKritVal("txb00","lonro30", t-period.dtb)  ).
   run setKritVal("SO_lonrio",t-period.pid, getStoredKritVal("txb00","lonrio", t-period.dtb)  ).
   run setKritVal("SO_lonrp",t-period.pid, getStoredKritVal("txb00","lonrp", t-period.dtb)  ).

   run setKritVal("lonprov",t-period.pid, getStoredKritVal("txb","lonprov", t-period.dtb)  ).
   run setKritVal("lonast",t-period.pid, getStoredKritVal("all","lonast", t-period.dtb)  ).

   run setKritVal("astSoft",t-period.pid, getStoredKritVal("txb00","astSoft", t-period.dtb)  ).
   run setKritVal("taxAst",t-period.pid, getStoredKritVal("txb00","taxAst", t-period.dtb)  ).

   run setKritVal("assets_other",t-period.pid, getStoredKritVal("all","assets_other", t-period.dtb)  ).
   run setKritVal("assets_total",t-period.pid, getStoredKritVal("all","assets_total", t-period.dtb)  ).

   run setKritVal("SO_dueToBanks",t-period.pid, getStoredKritVal("txb00","SO_dueToBanks", t-period.dtb)  ).
   run setKritVal("depo",t-period.pid, getStoredKritVal("txb","depo", t-period.dtb) + getStoredKritVal("txb00","SO_depo", t-period.dtb)  ).
   run setKritVal("depor",t-period.pid, getStoredKritVal("txb","depor", t-period.dtb)  ).
   run setKritVal("depov",t-period.pid, getStoredKritVal("txb","depov", t-period.dtb)  ).
   run setKritVal("depov1",t-period.pid, getStoredKritVal("txb","depov1", t-period.dtb)  ).
   run setKritVal("depov2",t-period.pid, getStoredKritVal("txb","depov2", t-period.dtb)  ).
   run setKritVal("depov3",t-period.pid, getStoredKritVal("txb","depov3", t-period.dtb)  ).
   run setKritVal("depov%",t-period.pid, getStoredKritVal("txb","depov%", t-period.dtb)  ).
   run setKritVal("depoSM",t-period.pid, getStoredKritVal("txb","depoSM", t-period.dtb)  ).
   run setKritVal("depoSMv",t-period.pid, getStoredKritVal("txb","depoSMv", t-period.dtb)  ).
   run setKritVal("depoSM1",t-period.pid, getStoredKritVal("txb","depoSM1", t-period.dtb)  ).
   run setKritVal("depoSM2",t-period.pid, getStoredKritVal("txb","depoSM2", t-period.dtb)  ).
   run setKritVal("depoSM3",t-period.pid, getStoredKritVal("txb","depoSM3", t-period.dtb)  ).
   run setKritVal("depoSM%",t-period.pid, getStoredKritVal("txb","depoSM%", t-period.dtb)  ).
   run setKritVal("depoCORP",t-period.pid, getStoredKritVal("txb","depoCORP", t-period.dtb)  ).
   run setKritVal("depoCORPv",t-period.pid, getStoredKritVal("txb","depoCORPv", t-period.dtb)  ).
   run setKritVal("depoCORP1",t-period.pid, getStoredKritVal("txb","depoCORP1", t-period.dtb)  ).
   run setKritVal("depoCORP2",t-period.pid, getStoredKritVal("txb","depoCORP2", t-period.dtb)  ).
   run setKritVal("depoCORP3",t-period.pid, getStoredKritVal("txb","depoCORP3", t-period.dtb)  ).
   run setKritVal("depoCORP%",t-period.pid, getStoredKritVal("txb","depoCORP%", t-period.dtb)  ).

   run setKritVal("SO_depo",t-period.pid, getStoredKritVal("txb00","SO_depo", t-period.dtb)  ).
   run setKritVal("SO_depov",t-period.pid, getStoredKritVal("txb00","SO_depov", t-period.dtb)  ).
   run setKritVal("SO_depov1",t-period.pid, getStoredKritVal("txb00","SO_depov1", t-period.dtb)  ).
   run setKritVal("SO_depov2",t-period.pid, getStoredKritVal("txb00","SO_depov2", t-period.dtb)  ).
   run setKritVal("SO_depov3",t-period.pid, getStoredKritVal("txb00","SO_depov3", t-period.dtb)  ).
   run setKritVal("SO_depov%",t-period.pid, getStoredKritVal("txb00","SO_depov%", t-period.dtb)  ).

   run setKritVal("depoGAR",t-period.pid, getStoredKritVal("txb","depoGAR", t-period.dtb) + getStoredKritVal("txb00","SO_depoGAR", t-period.dtb)  ).
   run setKritVal("SO_privlSr",t-period.pid, getStoredKritVal("txb00","SO_privlSr", t-period.dtb)  ).
   run setKritVal("SO_dolgObiaz",t-period.pid, getStoredKritVal("txb00","SO_dolgObiaz", t-period.dtb)  ).
   run setKritVal("SO_nalogObiaz",t-period.pid, getStoredKritVal("txb00","SO_nalogObiaz", t-period.dtb)  ).
   run setKritVal("docSetCredit",t-period.pid, getStoredKritVal("all","docSetCredit", t-period.dtb)  ).
   run setKritVal("SO_prochieObiaz",t-period.pid, getStoredKritVal("txb","obiazPROCHIE", t-period.dtb) +  getStoredKritVal("txb00","SO_prochieObiaz", t-period.dtb)  ).

   run setKritVal("SO_subordDolg",t-period.pid, getStoredKritVal("txb00","SO_subordDolg", t-period.dtb)  ).

   run setKritVal("SO_obiazatelstva",t-period.pid, getStoredKritVal("txb00","SO_obiazatelstva", t-period.dtb) + getStoredKritVal("txb","itogo_obiazatelstva", t-period.dtb) ).

  /* run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_ustkapital", t-period.dtb)  ).*/

   run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_Aksion_capital", t-period.dtb)  ).
   run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_Privelig_capital", t-period.dtb)  ).
   run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_Adjust_provision_account", t-period.dtb)  ).
   run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_Reserve", t-period.dtb)  ).
   run setKritVal("SO_ustkapital",t-period.pid, getStoredKritVal("txb00","SO_Ner_other_reserve", t-period.dtb)  ).


   run setKritVal("SO_Aksion_capital",t-period.pid, getStoredKritVal("txb00","SO_Aksion_capital", t-period.dtb)  ).
   run setKritVal("SO_Privelig_capital",t-period.pid, getStoredKritVal("txb00","SO_Privelig_capital", t-period.dtb)  ).

   run setKritVal("SO_Adjust_provision_account",t-period.pid, getStoredKritVal("all","SO_Adjust_provision_account", t-period.dtb)  ). /*TZ1120*/

   run setKritVal("SO_Reserve",t-period.pid, getStoredKritVal("txb00","SO_Reserve", t-period.dtb)  ).
   run setKritVal("SO_Ner_dohod_pred",t-period.pid, getStoredKritVal("txb00","SO_Ner_dohod_pred", t-period.dtb)  ).
   run setKritVal("SO_Ner_dohod_tekuch",t-period.pid, getStoredKritVal("txb00","SO_Ner_dohod_tekuch", t-period.dtb)  ).

   run setKritVal("SO_Net_profit_loss",t-period.pid, getStoredKritVal("txb00","SO_Net_profit_loss", t-period.dtb)  ). /*TZ1120*/
   run setKritVal("SO_Retained_earnings",t-period.pid, getStoredKritVal("txb00","SO_Retained_earnings", t-period.dtb)  ). /*TZ1120*/

   run setKritVal("SO_Ner_other_reserve",t-period.pid, getStoredKritVal("txb00","SO_Ner_other_reserve", t-period.dtb)  ).


   run setKritVal("SO_itoge_obiaz",t-period.pid, getKritVal("SO_ustkapital",t-period.pid) + getKritVal("SO_obiazatelstva",t-period.pid) ).

   run setKritVal("londoh_banks",t-period.pid, getStoredKritVal("txb00","londoh_banks", t-period.dtb)  ).

   run setKritVal("londoh_clients",t-period.pid,
           getStoredKritVal("txb","londoh_r", t-period.dtb) +
           getStoredKritVal("txb","londoh_s", t-period.dtb) +
           getStoredKritVal("txb","londoh_c", t-period.dtb) +
           getStoredKritVal("txb00","londoh_clients", t-period.dtb)  ).

   run setKritVal("londoh",t-period.pid,
     getStoredKritVal("txb00","londoh_banks", t-period.dtb) +
     getKritVal("londoh_clients",t-period.pid) +
     getStoredKritVal("txb00","londoh_secur", t-period.dtb) +
     getStoredKritVal("txb00","londoh_other", t-period.dtb)  ).


   run setKritVal("londoh_r",t-period.pid, getStoredKritVal("txb","londoh_r", t-period.dtb)  ).
   run setKritVal("londoh_s",t-period.pid, getStoredKritVal("txb","londoh_s", t-period.dtb)  ).
   run setKritVal("londoh_c",t-period.pid, getStoredKritVal("txb","londoh_c", t-period.dtb)  ).
   run setKritVal("londHO",t-period.pid, getStoredKritVal("txb00","londoh_clients", t-period.dtb)  ).
   run setKritVal("londoh_secur",t-period.pid, getStoredKritVal("txb00","londoh_secur", t-period.dtb)  ).
   run setKritVal("londoh_other",t-period.pid, getStoredKritVal("txb00","londoh_other", t-period.dtb)  ).


   run setKritVal("SO_rashod_deposit",t-period.pid,
           getStoredKritVal("txb","intRozn", t-period.dtb) +
           getStoredKritVal("txb","intMsb", t-period.dtb) +
           getStoredKritVal("txb","intCorporate", t-period.dtb) +
           getStoredKritVal("txb00","SO_rashod_deposit", t-period.dtb) ).

   run setKritVal("SO_rashod",t-period.pid,
           getKritVal("SO_rashod_deposit",t-period.pid) +
           getStoredKritVal("txb00","SO_rashod_bank", t-period.dtb) +
           getStoredKritVal("txb00","SO_rashod_sen", t-period.dtb) +
           getStoredKritVal("txb00","SO_rashod_subDolg", t-period.dtb) +
           getStoredKritVal("txb00","SO_pref_shares", t-period.dtb) +
           getStoredKritVal("txb00","SO_rashod_prochie", t-period.dtb) ).

   run setKritVal("SO_londoh_r",t-period.pid, getStoredKritVal("txb","intRozn", t-period.dtb)  ).
   run setKritVal("SO_londoh_s",t-period.pid, getStoredKritVal("txb","intMsb", t-period.dtb)  ).
   run setKritVal("SO_londoh_c",t-period.pid, getStoredKritVal("txb","intCorporate", t-period.dtb)  ).
   run setKritVal("SO_londHO",t-period.pid, getStoredKritVal("txb00","SO_rashod_deposit", t-period.dtb)  ).
   run setKritVal("SO_rashod_bank",t-period.pid, getStoredKritVal("txb00","SO_rashod_bank", t-period.dtb)  ).
   run setKritVal("SO_rashod_sen",t-period.pid, getStoredKritVal("txb00","SO_rashod_sen", t-period.dtb)  ).
   run setKritVal("SO_rashod_subDolg",t-period.pid, getStoredKritVal("txb00","SO_rashod_subDolg", t-period.dtb)  ).
   run setKritVal("SO_pref_shares",t-period.pid, getStoredKritVal("txb00","SO_pref_shares", t-period.dtb)  ).
   run setKritVal("SO_rashod_prochie",t-period.pid, getStoredKritVal("txb00","SO_rashod_prochie", t-period.dtb)  ).

   run setKritVal("net_incom",t-period.pid, getStoredKritVal("all","net_incom", t-period.dtb)  ).

   run setKritVal("com_incom",t-period.pid, getStoredKritVal("all","com_incom", t-period.dtb)  ).
   run setKritVal("com_incom1",t-period.pid, getStoredKritVal("txb","com_incom1", t-period.dtb)  ).
   run setKritVal("com_incom2",t-period.pid, getStoredKritVal("txb","com_incom2", t-period.dtb)  ).
   run setKritVal("com_incom3",t-period.pid, getStoredKritVal("txb","com_incom3", t-period.dtb)  ).
   run setKritVal("SO_com_incom",t-period.pid, getStoredKritVal("txb00","com_incom", t-period.dtb)  ).
   run setKritVal("com_exp",t-period.pid, getStoredKritVal("all","com_exp", t-period.dtb)  ).
   run setKritVal("com_other1003",t-period.pid, getStoredKritVal("all","com_other1003", t-period.dtb)  ).
   run setKritVal("com_FXincome1003",t-period.pid, getStoredKritVal("all","com_FXincome1003", t-period.dtb)  ).
   run setKritVal("com_FXexpense1003",t-period.pid, getStoredKritVal("all","com_FXexpense1003", t-period.dtb)  ).
   run setKritVal("com_NetCommFXincome1003",t-period.pid, getStoredKritVal("all","com_NetCommFXincome1003", t-period.dtb)  ).


   /*message "ЦО" getStoredKritVal("txb00","com_exp", t-period.dtb)  t-period.dtb view-as alert-box.
   message "Филиалы TXB01" getStoredKritVal("TXB01","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB02" getStoredKritVal("TXB02","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB03" getStoredKritVal("TXB03","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB04" getStoredKritVal("TXB04","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB05" getStoredKritVal("TXB05","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB06" getStoredKritVal("TXB06","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB07" getStoredKritVal("TXB07","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB08" getStoredKritVal("TXB08","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB09" getStoredKritVal("TXB09","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB10" getStoredKritVal("TXB10","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB11" getStoredKritVal("TXB11","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB12" getStoredKritVal("TXB12","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB13" getStoredKritVal("TXB13","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB14" getStoredKritVal("TXB14","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB15" getStoredKritVal("TXB15","com_exp", t-period.dtb) view-as alert-box.
   message "Филиалы TXB16" getStoredKritVal("TXB16","com_exp", t-period.dtb) view-as alert-box.


def var SS as deci.

 SS = getStoredKritVal("TXB01","com_exp", t-period.dtb) +
  getStoredKritVal("TXB02","com_exp", t-period.dtb) +
  getStoredKritVal("TXB03","com_exp", t-period.dtb) +
  getStoredKritVal("TXB04","com_exp", t-period.dtb) +
  getStoredKritVal("TXB05","com_exp", t-period.dtb) +
  getStoredKritVal("TXB06","com_exp", t-period.dtb) +
  getStoredKritVal("TXB07","com_exp", t-period.dtb) +
  getStoredKritVal("TXB08","com_exp", t-period.dtb) +
  getStoredKritVal("TXB09","com_exp", t-period.dtb) +
  getStoredKritVal("TXB10","com_exp", t-period.dtb) +
  getStoredKritVal("TXB11","com_exp", t-period.dtb) +
  getStoredKritVal("TXB12","com_exp", t-period.dtb) +
  getStoredKritVal("TXB13","com_exp", t-period.dtb) +
  getStoredKritVal("TXB14","com_exp", t-period.dtb) +
  getStoredKritVal("TXB15","com_exp", t-period.dtb) +
  getStoredKritVal("TXB16","com_exp", t-period.dtb) +
  getStoredKritVal("txb00","com_exp", t-period.dtb).

  message "Поодиночке!!! = " SS view-as alert-box.

  message "Все сразу = " getStoredKritVal("all","com_exp", t-period.dtb) view-as alert-box.*/


   run setKritVal("com_incom_all",t-period.pid, getStoredKritVal("all","com_incom_all", t-period.dtb)  ).

   run setKritVal("com_inexp",t-period.pid, getStoredKritVal("all","com_inexp", t-period.dtb)  ).
   run setKritVal("com_inexp_val",t-period.pid, getStoredKritVal("txb00","com_inexp_val", t-period.dtb)  ).

   run setKritVal("com_socpay",t-period.pid, getStoredKritVal("all","com_socpay", t-period.dtb)  ).
   run setKritVal("com_bon",t-period.pid, getStoredKritVal("all","com_bon", t-period.dtb)  ).
   run setKritVal("com_trip",t-period.pid, getStoredKritVal("all","com_trip", t-period.dtb)  ).
   run setKritVal("com_renpay",t-period.pid, getStoredKritVal("all","com_renpay", t-period.dtb)  ).
   run setKritVal("com_amort",t-period.pid, getStoredKritVal("all","com_amort", t-period.dtb)  ).
   run setKritVal("com_taxgov",t-period.pid, getStoredKritVal("all","com_taxgov", t-period.dtb)  ).
   run setKritVal("com_mark",t-period.pid, getStoredKritVal("all","com_mark", t-period.dtb)  ).
   run setKritVal("com_call",t-period.pid, getStoredKritVal("all","com_call", t-period.dtb)  ).
   run setKritVal("com_secur",t-period.pid, getStoredKritVal("all","com_secur", t-period.dtb)  ).
   run setKritVal("com_admin",t-period.pid, getStoredKritVal("all","com_admin", t-period.dtb)  ).
   run setKritVal("com_audit",t-period.pid, getStoredKritVal("all","com_audit", t-period.dtb)  ).
   run setKritVal("com_other",t-period.pid, getStoredKritVal("all","com_other", t-period.dtb)  ).
   run setKritVal("com_exp_all",t-period.pid, getStoredKritVal("all","com_exp_all", t-period.dtb)  ).

   run setKritVal("com_precost",t-period.pid, getStoredKritVal("txb00","com_precost", t-period.dtb) +  getStoredKritVal("txb","com_braincom", t-period.dtb)  ).

   run setKritVal("com_prov",t-period.pid, getStoredKritVal("all","com_prov", t-period.dtb)  ).
   run setKritVal("com_prov1",t-period.pid, getStoredKritVal("all","com_prov1", t-period.dtb)  ).
   run setKritVal("com_prov2",t-period.pid, getStoredKritVal("all","com_prov2", t-period.dtb)  ).
   /*com_capcost + com_boiall*/
   run setKritVal("com_postcost",t-period.pid, getStoredKritVal("txb00",/*"com_capcost"*/ "com_postcost" , t-period.dtb) + getStoredKritVal("txb",/*"com_postcost"*/ "com_precost" /*"com_boiall"*/, t-period.dtb)  ).

   run setKritVal("com_all_postcost",t-period.pid, /*getStoredKritVal("txb","", t-period.dtb) */ 0 ).

   run setKritVal("lc",t-period.pid, getStoredKritVal("all","lc", t-period.dtb)  ).
   run setKritVal("lg",t-period.pid, getStoredKritVal("all","lg", t-period.dtb)  ).

   run setKritVal("openfx",t-period.pid, getStoredKritVal("all","openfx", t-period.dtb)  ).

    for each crc where crc.crc <> 5 no-lock.
     run setKritVal( "openfx" + string(crc.crc) , t-period.pid , getStoredKritVal("all","openfx" + string(crc.crc),t-period.dtb)).
    end.





end.











def stream rep_br.

 /*output stream rep_br to rep_br.htm.*/

 repname = "rep_br_fact_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
 output stream rep_br to value(repname).

put stream rep_br "<html><head><title>Управленческая отчетность факт - консолидированный отчет</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep_br unformatted
    "<b>" + v-nbank1 + "</b><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td width=700></td>" skip.

for each t-period no-lock:
   /* put stream rep_br unformatted "<td>" string(t-period.dtb,"99/99/9999") "</td>" skip.*/
     put stream rep_br unformatted "<td>" replace(string(t-period.dtb,"99/99/9999"),'/','.') "-" replace(string(t-period.dte,"99/99/9999"),'/','.') "</td>" skip.
end.

put stream rep_br unformatted "</tr>" skip.

for each t-krit no-lock:
    put stream rep_br unformatted "<tr>" skip.
    if t-krit.kcode = "-" then do:
      if t-krit.color_code then put stream rep_br unformatted "<td style=""font:bold"" bgcolor=""#C0C0C0"">" t-krit.des_en "</td>" skip.
      else put stream rep_br unformatted "<td style=""font:bold"">" t-krit.des_en "</td>" skip.
    end.
    else do:
        put stream rep_br unformatted "<td".
        if t-krit.bold_code  = yes then put stream rep_br unformatted " style=""font:bold"" ".
        if t-krit.color_code = yes then put stream rep_br unformatted " bgcolor=""#C0C0C0"" ".
        put stream rep_br unformatted ">" fill("&nbsp;&nbsp;&nbsp;&nbsp;",t-krit.level - 1) replace(trim(t-krit.des_en),' ',"&nbsp;") "</td>" skip.

        for each t-period no-lock:
            find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = t-krit.kid and t-kritval.pid = t-period.pid no-lock no-error.
            if avail t-kritval then put stream rep_br unformatted "<td>" replace(trim(string( t-kritval.sum / 1000 ,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            else put stream rep_br unformatted "<td></td>" skip.
        end.
    end.
    put stream rep_br unformatted "</tr>" skip.
end.

put stream rep_br unformatted "</table></body></html>" skip.

output stream rep_br close.

/*unix silent cptwin rep_br.htm excel.*/

message "Добавить в отчет данные филиалов?" view-as alert-box question buttons ok-cancel title "" update choice as logical.
if not choice then do:
   unix silent value("cptwin " + repname + " excel").
end.

v-result = "".
input through value ("mv " + repname + " /data/reports/uprav/" + repname ).
repeat:
  import unformatted v-result.
end.

if v-result <> "" then do:
    message " Произошла ошибка при копировании отчета - " v-result.
end.

repname = replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
if choice then do:

  output to run.cmd.
  put unformatted "del c:\\tmp\\rep_br.htm~n".
  put unformatted "del c:\\tmp\\rpt.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB01.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB02.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB03.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB04.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB05.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB06.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB07.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB08.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB09.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB10.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB11.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB12.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB13.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB14.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB15.htm~n".
  put unformatted "del c:\\tmp\\rpt_TXB16.htm~n".
  output close.
  input through value ( "scp -q run.cmd Administrator@`askhost`:c:/tmp/run.cmd" ) .

  input through value ( "scp -q /data/reports/uprav/rep_br_fact_" + repname + " Administrator@`askhost`:c:/tmp/rep_br.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_" + repname + " Administrator@`askhost`:c:/tmp/rpt.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB01_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB01.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB02_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB02.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB03_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB03.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB04_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB04.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB05_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB05.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB06_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB06.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB07_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB07.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB08_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB08.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB09_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB09.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB10_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB10.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB11_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB11.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB12_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB12.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB13_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB13.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB14_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB14.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB15_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB15.htm" ) .
  input through value ( "scp -q /data/reports/uprav/rpt_fact_TXB16_" + repname + " Administrator@`askhost`:c:/tmp/rpt_TXB16.htm" ) .

  input through value ( "scp -q /data/reports/uprav/consolid.xlsm Administrator@`askhost`:c:/tmp/consolid.xlsm" ) .

  output to run.cmd.
  put unformatted "start excel c:\\tmp\\consolid.xlsm".
  output close.

  input through value ( "scp -q run.cmd Administrator@`askhost`:c:/tmp/run.cmd" ) .

end.

