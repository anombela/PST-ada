--Alfonso Nombela Moreno

package Chat_Messages is
	
	type Message_Type is (Init, Reject, Confirm, Writer, Logout);
	type Seq_N_T is mod Integer'Last;
	
end Chat_Messages;
