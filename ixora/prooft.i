find {1} where {1}.{1} eq trxbal.acc no-lock no-error.
if available {1} then do:
if trxbal.level ge 1 and trxbal.level le 5 then do:
if trxbal.dam ne {1}.dam[trxbal.level]
then put stream s-err {1}.{1}
" trxbal.dam ne {1}.dam[" trxbal.level format "9" "] " trxbal.dam
{1}.dam[trxbal.level] skip.
if trxbal.cam ne {1}.cam[trxbal.level]
then put stream s-err {1}.{1}
" trxbal.cam ne {1}.cam[" trxbal.level format "9" "] " trxbal.cam
{1}.cam[trxbal.level] skip.
end.
v-gl = {1}.gl.
find trxlevgl where trxlevgl.gl eq {1}.gl and trxlevgl.subled eq "{1}"
and trxlevgl.level eq trxbal.level no-lock no-error.
end.
else put stream s-err "Not found {1} " {1}.{1} skip.
