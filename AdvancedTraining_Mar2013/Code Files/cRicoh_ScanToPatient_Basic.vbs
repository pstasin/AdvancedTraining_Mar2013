Const DSN = "AdvancedTraining"

Sub Form_OnLoad(Form)
	Call Form.StatusMsg("On Form Load for MRN (B)")

	Call Form.UpdateLabelField("Label", 3, "Press the 'MRN' button to input the MRN #")	

	Call Form.SetFieldVisible("Patient Name", False)
	Call Form.SetFieldVisible("DOB", False)
End Sub
 

Function Form_OnScan(Form)

End Function


Sub Field_OnChanged(Form, FieldName, FieldValue)
	Call Form.StatusMsg("Field onChange was called for field name = " & FieldName)
	Call Form.StatusMsg(".. value changed = " & FieldValue)

	Dim patientName
	Dim patientDOB
	Dim patientDetails : patientDetails = GetPatientByMRN(FieldValue, patientName, patientDOB)
	
	If (Len(patientDetails) = 0) Then
		Call Form.UpdateLabelField("Label", 3, "No patient find with that MRN, please try again")	

		Call Form.SetFieldVisible("Patient Name", False)
		Call Form.SetFieldVisible("DOB", False)		
	Else
		Call Form.UpdateLabelField("Label", 3, "Press the 'MRN' button to input the MRN #")	
				
		Call Form.SetFieldValue("Patient Name", patientName)
		Call Form.SetFieldValue("DOB", patientDOB)
	
		Call Form.SetFieldVisible("Patient Name", True)
		Call Form.SetFieldVisible("DOB", True)		
	End If
End Sub


Function Field_OnValidate(FieldName, FieldValue)

End Function


Sub Button_OnClick(Form, ButtonName)

End Sub

' Call Test()
Sub Test
	Dim patientName
	Dim patientDOB
	Dim patientDetails : patientDetails = GetPatientByMRN(123459, patientName, patientDOB)
	msgbox patientDetails
	msgbox patientName
	msgbox patientDOB
End Sub
	
Function GetPatientByMRN(ByVal mrn, ByRef patientName, ByRef patientDOB)
	Dim patientList : patientList = ""
	Dim result_mrn
	Dim result_lastName
	Dim result_firstName
	Dim result_DOB

	Dim Conn 
	Set Conn = CreateObject("ADODB.Connection")
		
	Dim CmdString : CmdString = "SELECT MRN, LastName, FirstName, DOB"
	CmdString = CmdString & " FROM Patient "
	CmdString = CmdString & " WHERE MRN='"&mrn&"'"
	
	ConnString = DSN 	
	
	Conn.Open ConnString, "", ""
	Set Rs = CreateObject("ADODB.Recordset")

	Rs.Open CmdString, Conn
		
	Do While Not Rs.eof	
		result_mrn = Rs("MRN")
		result_lastName = Rs("LastName")
		result_firstName = Rs("FirstName")
		result_DOB = Rs("DOB")
		
		patientList = result_lastName & ", " & result_firstName & " (" & result_dob & ") #" & result_mrn
		
		patientName = result_lastName & ", " & result_firstName
		patientDOB = result_dob
		Rs.MoveNext
	Loop
				
	Rs.Close
	Set Rs = Nothing

	Conn.Close
	Set Conn = Nothing  
	
	GetPatientByMRN = patientList
End Function



