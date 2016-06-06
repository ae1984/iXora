/* lclimit.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Лимиты - создание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1
 * AUTHOR
        16/09/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        02/03/2012 id00810 - скорректирован расчет текущей суммы v-limsumcur
        14/06/2013 galina - ТЗ1552
*/

{mainhead.i LCLIMIT}

def new shared var s-number    as int.
def new shared var v-cifname   as char.
def new shared var v-limsts    as char.
def new shared var v-limerrdes as char.
def new shared var v-find      as logi.
def new shared var v-limsumcur as deci.
def new shared var v-limsumorg as deci.
def new shared var v-limdtexp  as date.
def new shared var v-limcrc1   as char.
def new shared var v-limcrc2   as char.
def new shared var s-ftitle    as char init ' LIMIT for LETTER OF CREDIT '.
def new shared var s-namef     as char.

def new shared var s-lon like lon.lon.


def var v-chose  as logi no-undo.
def var v-chose1 as logi no-undo.
def var v-lang   as char no-undo.
def var v-per    as int  no-undo.

def new shared var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "lclimit"
 &head       = "lclimit"
 &headkey    = "cif"
 &framename  = "frlclimit"
 &formname   = "lclim"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlclimit do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = "assign s-cif       = ''
                       v-find      = no
                       v-limsumcur = 0
                       v-limsumorg = 0
                       v-limcrc1   = ''
                       v-limcrc2   = ''
                       v-limdtexp  = ?.
                display s-namef with frame frlclimit.
                do on error undo,return:
                    update  s-cif with frame frlclimit.
                    find first cif where cif.cif = s-cif no-lock no-error.
                    if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                    display v-cifname with frame frlclimit.
                    message 'Do you want to create a new Limit?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
                    update v-chose.
                end. "
 &presubprg = "if v-chose then "
 &postadd = " assign lclimit.number = s-number
                     lclimit.sts    = 'NEW'
                     lclimit.bank   = s-ourbank
                     lclimit.rwho   = g-ofc
                     lclimit.rwhn   = g-today.
              find current lclimit no-lock no-error.
              v-limsts = lclimit.sts.
              s-lon = s-cif + 'LCLIM' + trim(string(s-number,'>>99')).
              display s-number v-limsts with frame frlclimit. "
 &prefind = " assign v-find      = yes
                     s-cif       = ''
                     s-number    = 0
                     v-cifname   = ''
                     v-limsts    = ''
                     v-limerrdes = ''
                     v-limsumcur = 0
                     v-limsumorg = 0
                     v-limcrc1   = ''
                     v-limcrc2   = ''
                     v-limdtexp  = ?.
              display s-namef with frame frlclimit.
              update s-cif with frame frlclimit.
              find first cif where cif.cif = s-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frlclimit.
              repeat on endkey undo, return:
               update s-number with frame frlclimit.
               find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
               if not avail lclimit then run lclimhelp.
               find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
               if avail lclimit then do:
                   v-limsts = lclimit.sts.
                   find cif where cif.cif = lclimit.cif no-lock no-error.
                   if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                   display v-cifname s-cif s-number v-limsts with frame frlclimit.
                   v-chose = yes.
                   leave.
               end.
              end.
              find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'Amount' no-lock no-error.
              if avail lclimith and trim(lclimith.value1) <> '' then v-limsumorg = deci(lclimith.value1).

              if lclimit.sts = 'cls' or lclimit.sts = 'cnl' then v-limsumcur = 0.
              else
              for each lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = s-cif and lclimitres.number = s-number and lclimitres.jh > 0 no-lock.
                  if substr(lclimitres.dacc,1,2) = '61' then v-limsumcur = v-limsumcur + lclimitres.amt.
                  else v-limsumcur = v-limsumcur - lclimitres.amt.
              end.

              find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
              if avail lclimith and trim(lclimith.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lclimith.value1)) no-lock no-error.
                if avail crc then assign v-limcrc1 = crc.code v-limcrc2 = crc.code.
              end.
              display v-limsumorg v-limsumcur with frame frlclimit.
              display v-limcrc1 v-limcrc2 with frame frlclimit.

              find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'DtExp' no-lock no-error.
              if avail lclimith and lclimith.value1 <> ? then do:
                 v-limdtexp = date(lclimith.value1).
                 display v-limdtexp with frame frlclimit.
              end. "
 &postfind = " if avail lclimit then v-limsts = lclimit.sts.
               if v-limsts = 'Err' then do:
                   find first lclimith where lclimith.cif = s-cif and lclimit.number = s-number and lclimith.kritcode = 'Errdes' no-lock no-error.
                   if avail lclimith then v-limerrdes = lclimith.value1.
               end.
               s-lon = s-cif + 'LCLIM' + trim(string(s-number,'>>99')).
               display v-limsts v-limerrdes with frame frlclimit.  "
 &numprg = "lclimcre"
 &subprg = "lclimedt"
 &end = " g-lang = v-lang. "
}