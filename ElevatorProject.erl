-module(elevatorProject).
-compile(export_all).

% - Fl - is a Floor shortcut
% - Elev - is a Elevator shortcut
init_system(Fl_Amount,
            First_Elev_Start_Fl,
            Second_Elev_Start_Fl) when is_integer(Fl_Amount)
                              andalso is_integer(First_Elev_Start_Fl)
                              andalso is_integer(Second_Elev_Start_Fl)
                              andalso First_Elev_Start_Fl >= 0
                              andalso Second_Elev_Start_Fl >= 0
                              andalso First_Elev_Start_Fl =< Fl_Amount
                              andalso Second_Elev_Start_Fl =< Fl_Amount
                              ->
  Raport_Manager_PID = spawn(elevatorProject, raport_manager, []),
  Draw_manager_PID = spawn(elevatorProject, draw_manager, []),

  put(raport_manager_PID, Raport_Manager_PID),
  put(draw_manager_PID, Draw_manager_PID),

  get(draw_manager_PID) ! {clear_board},
  timer:sleep(1000),
  get(raport_manager_PID) ! {start, First_Elev_Start_Fl, Second_Elev_Start_Fl},
  get(draw_manager_PID) ! {draw_board, Fl_Amount, First_Elev_Start_Fl, Second_Elev_Start_Fl}.
  % main_loop().

main_loop() ->
  io:format("TEST\n"),
  timer:sleep(1000),
  main_loop().

%
raport_manager() ->
  receive
    {start, A_Floor_Pos, B_Floor_Pos} ->
      io:format("Starting elevator system simulation.\nElevator A is currently on the ~p floor and\nElevator B is currently on the ~p floor.\n", [A_Floor_Pos, B_Floor_Pos]),
      raport_manager();
    {update_info} ->
      io:format("Nothing to update\n"),
      raport_manager();
    _ ->
      io:format("Received error message in raport_manager function\n"),
      raport_manager()
    end.

draw_manager() ->
  receive
    {draw_board, Fl_Amount, First_Elev_Fl, Second_Elev_Fl} ->
      io:format("Drawing board:\n"),
      % draw_board(Fl_Amount),
      draw_board_3(Fl_Amount, First_Elev_Fl, Second_Elev_Fl),
      draw_manager();
    {clear_board} ->
      io:format("\e[H\e[J"),
      draw_manager();
    _ ->
      io:format("Received error message in draw_manager function\n"),
      draw_manager()
  end.

draw_board(0) -> io:format("\n\t0|  | |  | | \n");
draw_board(X) ->
  io:format("\n\t~p|  | |  | | ", [X]),
  draw_board(X-1).

% end_drawing
draw_board_3(0, _, _) ->
  io:format("\n");
% |X| |X|
draw_board_3(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when First_Elev_Fl == Second_Elev_Fl
                                                    andalso First_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  |X|  |X| ", [Fl_Amount]),
  draw_board_3(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% |X| | |
draw_board_3(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when First_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  |X|  | | ", [Fl_Amount]),
  draw_board_3(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% | | |X|
draw_board_3(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when Second_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  | |  |X| ", [Fl_Amount]),
  draw_board_3(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% | | | |
draw_board_3(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) ->
  io:format("\n\t~p|  | |  | | ", [Fl_Amount]),
  draw_board_3(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl).
