function write_slide(direction)

fid = fopen('../control_interface/click.log', 'at');
fprintf(fid, 's %s \n', direction);
fclose(fid);

end