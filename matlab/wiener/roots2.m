function r = roots2(c)
echo off;
if (size(c,1) ~= 3 | size(c,2) ~= 1) & ...
   (size(c,1) ~= 1 & size(c,2) ~= 3)
	error('vector "c" must have 3 items');
end
d = c(2)^2 - 4 * c(1) * c(3);
if d < 0
   warning(sprintf('discriminant %g is negative', d));
end
r(1) = (- c(2) + sqrt(d))/ 2 * c(1);
r(2) = (- c(2) - sqrt(d))/ 2 * c(1);

