# -*- encoding : utf-8 -*-
class Cgs8086Setting 
	LOGINURL           = "http://cgs1.stc.gov.cn:8086/kszzyy/specialLogin_login.action"
	REGISTER           = "http://cgs1.stc.gov.cn:8086/kszzyy/specialLogin_toRegister.action"
	POST_REGISTER      = "http://cgs1.stc.gov.cn:8086/kszzyy/specialLogin_register.action"
	SENDMSG            = "http://cgs1.stc.gov.cn:8086/kszzyy/specialLogin_sendMsg.action"
	LOGINCODE 		   = "http://cgs1.stc.gov.cn:8086/kszzyy/verifyCode.action?isLogin=1"
	
	MAINURL            = "http://cgs1.stc.gov.cn:8086/kszzyy/main.jsp"
	
	EXAM1APPLY         = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_toExam1Destine.action"
	EXAM1LIST          = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_toList.action"
	SEARCH1            = 'http://cgs1.stc.gov.cn:8086/kszzyy/exam1_list.action'
	EXAM1DESTINECANCEL = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_toExam1DestineCancel.action"
	EXAM1CANCEL        = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_toExam1ExamCancel.action"
	EXAM1CANCELYYDJ    = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_cancelYydj.action"
	EXAM1DESTINE       = "http://cgs1.stc.gov.cn:8086/kszzyy/exam1_destine.action"


	EXAM2APPLY         = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_toExam2Destine.action"
	EXAM2LIST          = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_toList.action"
	SEARCH2 		   = 'http://cgs1.stc.gov.cn:8086/kszzyy/exam2_list.action'
	EXAM2DESTINECANCEL = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_toExam1DestineCancel.action"
	EXAM2CANCEL        = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_toExam1ExamCancel.action"
	EXAM2CANCELYYDJ    = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_cancelYydj.action"
	EXAM2DESTINE       = "http://cgs1.stc.gov.cn:8086/kszzyy/exam2_destine.action"

	EXAM3APPLY         = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_toExam3Destine.action"
	EXAM3LIST          = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_toList.action"
	SEARCH3 		   = 'http://cgs1.stc.gov.cn:8086/kszzyy/exam3_list.action'
	EXAM3DESTINECANCEL = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_toExam1DestineCancel.action"
	EXAM3CANCEL        = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_toExam1ExamCancel.action"
	EXAM3CANCELYYDJ    = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_cancelYydj.action"
	EXAM3DESTINE       = "http://cgs1.stc.gov.cn:8086/kszzyy/exam3_destine.action"

	EXAM4APPLY         = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_toExam4Destine.action"
	EXAM4LIST          = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_toList.action"
	SEARCH4 		   = 'http://cgs1.stc.gov.cn:8086/kszzyy/exam4_list.action'
	EXAM4DESTINECANCEL = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_toExam1DestineCancel.action"
	EXAM4CANCEL        = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_toExam1ExamCancel.action"
	EXAM4CANCELYYDJ    = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_cancelYydj.action"
	EXAM4DESTINE       = "http://cgs1.stc.gov.cn:8086/kszzyy/exam4_destine.action"

	
	FEE 			   = 'http://cgs1.stc.gov.cn:8086/kszzyy/student_doStudentFree.action'
	INFO 			   = 'http://cgs1.stc.gov.cn:8086/kszzyy/student_doStudentInfo.action'
end



# urls = [Setting1,Setting2,Setting3]
# retries = 0
# begin 
#  get(url[retries]::LOGIN)
# rescue TimeoutException #其实我不记得这个异常是啥了
#   retries = retries+1 
#   retry unless retries>2
# end
