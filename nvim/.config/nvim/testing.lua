function foo (a)
	print("foo", a)
	return coroutine.yield(2*)
end

co = coroutine.create(function (a,b)
	print("co-body", a, b)


 
