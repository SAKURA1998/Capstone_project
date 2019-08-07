function write_click(x, y)

fid = fopen('../control_interface/click.log', 'at');
fprintf(fid, 'c %d %d\n', x, y);
fclose(fid);

end