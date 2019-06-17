function result=func_calculate_intersection(a,b,h,w)
X = [(a^2*b - a*b^2 + b*h^2 + a*w^2 - (b*h*(b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 + a*w*((a + h)*(b + w)*(a - h)*(b - w)*(- a^2 + 2*a*b - b^2 + h^2 + w^2))^(1/2) - a*b^3*h + a*b*h*w^2))/(a^2*w^2 + b^2*h^2 - h^2*w^2))/(2*a*w),...
    -(a*b^2 + a^2*b + b*h^2 - a*w^2 - (b*h*(b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 + a*w*(-(a + h)*(b + w)*(a - h)*(b - w)*(a^2 + 2*a*b + b^2 - h^2 - w^2))^(1/2) + a*b^3*h - a*b*h*w^2))/(a^2*w^2 + b^2*h^2 - h^2*w^2))/(2*a*w),...
    (a^2*b - a*b^2 + b*h^2 + a*w^2 - (b*h*(b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 - a*w*((a + h)*(b + w)*(a - h)*(b - w)*(- a^2 + 2*a*b - b^2 + h^2 + w^2))^(1/2) - a*b^3*h + a*b*h*w^2))/(a^2*w^2 + b^2*h^2 - h^2*w^2))/(2*a*w),...
    -(a*b^2 + a^2*b + b*h^2 - a*w^2 - (b*h*(b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 - a*w*(-(a + h)*(b + w)*(a - h)*(b - w)*(a^2 + 2*a*b + b^2 - h^2 - w^2))^(1/2) + a*b^3*h - a*b*h*w^2))/(a^2*w^2 + b^2*h^2 - h^2*w^2))/(2*a*w)];
Y = [(b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 + a*w*((a + h)*(b + w)*(a - h)*(b - w)*(- a^2 + 2*a*b - b^2 + h^2 + w^2))^(1/2) - a*b^3*h + a*b*h*w^2)/(2*(a^2*w^2 + b^2*h^2 - h^2*w^2)),...
    (b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 + a*w*(-(a + h)*(b + w)*(a - h)*(b - w)*(a^2 + 2*a*b + b^2 - h^2 - w^2))^(1/2) + a*b^3*h - a*b*h*w^2)/(2*(a^2*w^2 + b^2*h^2 - h^2*w^2)),...
    (b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 - a*w*((a + h)*(b + w)*(a - h)*(b - w)*(- a^2 + 2*a*b - b^2 + h^2 + w^2))^(1/2) - a*b^3*h + a*b*h*w^2)/(2*(a^2*w^2 + b^2*h^2 - h^2*w^2)),...
    (b^2*h^3 - h^3*w^2 + a^2*b^2*h + a^2*h*w^2 - a*w*(-(a + h)*(b + w)*(a - h)*(b - w)*(a^2 + 2*a*b + b^2 - h^2 - w^2))^(1/2) + a*b^3*h - a*b*h*w^2)/(2*(a^2*w^2 + b^2*h^2 - h^2*w^2))];
positionX=find(X(:)<w&X(:)>0&Y(:)<h&Y(:)>0);
result=[X(positionX),Y(positionX)];
end