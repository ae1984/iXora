/* pkdefadres1.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Определение строки адреса прописки и фактического проживания по данным анкеты в формате, необходимом для КФМ
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        общая процедура ПК
 * AUTHOR
        25.02.2010 galina скопировала из с небольшими изменениями
 * BASES
        BANK COMM
 
 * CHANGES
 

*/



{global.i}

{pk.i}



def input parameter p-ln like pkanketa.ln.
def output parameter p-adres1 as char.
def output parameter p-adres2 as char.
def output parameter p-adresdel1 as char.
def output parameter p-adresdel2 as char.



if p-ln = 0 then return.



find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = p-ln no-lock no-error.

if not avail pkanketa then return.

def var v-adres as char extent 2.
def var v-adresdel as char extent 2.
def var v-adresfull as char init "city,street,house,apart".
def var v-adreslabel as char init "г. ,,д.,кв.".
def var i as integer.
def var n as integer.
def var v-data as char.
def var v-delim as char init "^".



do i = 1 to 2:

  v-adres[i] = "Казахстан,". 
  v-adresdel[i] = "Казахстан^". 

  do n = 1 to num-entries(v-adresfull):
    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = entry(n, v-adresfull) + string(i) no-lock no-error.

    /* разделитель добавлять всегда, даже если нет данных */

    if v-adresdel[i] <> "" then v-adresdel[i] = v-adresdel[i] + v-delim.
    if v-adres[i] <> "" then v-adres[i] = v-adres[i] + ", ".
    
    if avail pkanketh and pkanketh.value1 <> "" then do:
 
      /* найти значение из справочника, если надо */
      find pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
      if pkkrit.kritspr = "" then v-data = pkanketh.value1.
      else do:
        find bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = pkanketh.value1 no-lock no-error.
        if avail bookcod then v-data = bookcod.name.
        else do:
          find codfr where codfr.codfr = pkkrit.kritspr and codfr.code = pkanketh.value1 no-lock no-error.
          if avail codfr then v-data = codfr.name[1].
          else v-data = pkanketh.value1.
        end.
      end.
      v-data = trim(v-data).
      if v-data <> "" then do:
        v-adresdel[i] = v-adresdel[i] + v-data.      
        v-data = entry(n, v-adreslabel) + v-data.
        v-adres[i] = v-adres[i] + v-data.
      end.
    end.
  end.
  v-adres[i] =  v-adres[i]  +  ",". 
  v-adresdel[i] =  v-adresdel[i]  +  "^". 
end.



p-adres1 = v-adres[1].
if v-adres[2] = "" then p-adres2 = p-adres1.
                   else p-adres2 = v-adres[2].

p-adresdel1 = v-adresdel[1].
if v-adresdel[2] = "" then p-adresdel2 = p-adresdel1.
                     else p-adresdel2 = v-adresdel[2].

                     