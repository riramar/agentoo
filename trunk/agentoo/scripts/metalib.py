import sys,getopt,re
sys.path.insert(0, "/usr/lib/portage/pym")
import portage,portage_const,portage_dep

# TODO: use new names from trunk
isvalidatom = portage.isvalidatom
catpkgsplit = portage.catpkgsplit
catsplit = portage.catsplit
dep_getcpv = portage.dep_getcpv
dep_getkey = portage.dep_getkey

EXIT_SUCCESS = 0
EXIT_NORESULT = 1
EXIT_FAILURE = 2

HELP_WRAP_LIMIT = 12

settings = portage.config(clone=portage.settings)

# --help output, using optionmap to display option descriptions
def show_help(exitcode, optionmap, syntax):
	sys.stderr.write(("\nSyntax: "+syntax+"\n\n") % sys.argv[0])
	for m in optionmap:
		if len(m[1]) > HELP_WRAP_LIMIT:
			sys.stderr.write("\n%s\t%s :\n  %s\n" % tuple(m))
		else:
			sys.stderr.write(("%s\t%-"+str(HELP_WRAP_LIMIT)+"s : %s\n") % tuple(m))
		for o in m[2:-1]:
			sys.stderr.write("\t" + o)
	sys.stderr.write("\nValid keys are:\n")
	for k in portage.auxdbkeys:
		if not k[:6] == "UNUSED":
			sys.stderr.write("\t"+k+"\n")
	sys.stderr.write("\n")
	sys.exit(exitcode)

def resolve_dep_strings(cpv, keys, values):
	result = values[:]
	settings.setcpv(cpv)
	for i in range(0, len(keys)):
		if keys[i].find("DEPEND") >= 0 or keys[i] == "PROVIDE":
			result[i] = " ".join(portage.flatten(portage_dep.use_reduce(portage_dep.paren_reduce(values[i]), settings["USE"].split())))
	return result

def strip_atoms(keys, values):
	result = values[:]
	for i in range(0, len(values)):
		if keys[i] not in ["DEPEND", "RDEPEND", "PDEPEND", "CDEPEND", "*DEPEND", "PROVIDE"]:
			continue
		result[i] = ""
		parts = values[i].split()
		for x in parts:
			if isvalidatom(x):
				result[i] += dep_getkey(x)
			else:
				result[i] += x
			result[i] += " "
		result[i] = result[i].strip()
	return result

def metascan(db, keys, values, negated, scanlist=None, operator="or", resolveDepStrings=False, stripAtoms=False, partial=False, regex=False, catlimit=None, debug=0, verbose=False):

	if len(keys) != len(values) or len(keys) != len(negated):
		raise IndexError("argument length mismatch")

	if scanlist == None:
		scanlist = {}
		plist = db.cp_all()
		for p in plist:
			scanlist[p] = []
			for pv in db.cp_list(p):
				scanlist[p].append(pv)		

	resultlist = []

	for p in scanlist:
		if debug > 1:
			sys.stderr.write("Scanning package %s\n" % p)
		# check if we have a category restriction and if that's the case, skip this package if we don't have a match
		if catlimit != None and catsplit(p)[0] not in catlimit:
			if debug > 1:
				sys.stderr.write("Skipping package %s from category %s due to category limit (%s)\n" % (p, catsplit(p)[0], str(catlimit)))
			continue
		for pv in scanlist[p]:
			try:
				result = []
				# this is the slow part, also generates noise if portage cache out of date
				pvalues = db.aux_get(pv, keys)

			except KeyError:
				sys.stderr.write("Error while scanning %s\n" % pv)
				continue

			# save original values for debug
			if debug > 1:
				keys_uniq = []
				pvalues_orig = []
				for i in range(0, len(keys)):
					if not keys[i] in keys_uniq:
						keys_uniq.append(keys[i])
						pvalues_orig.append(pvalues[i])

			# remove conditional deps whose coditions aren't met
			if resolveDepStrings:
				pvalues = resolve_dep_strings(pv, keys, pvalues)
		
			# we're only interested in the cat/pkg stuff from an atom here, so strip the rest
			if stripAtoms:
				pvalues = strip_atoms(keys, pvalues)

			# report also partial matches, e.g. "foo" in "foomatic"
			if partial or regex:
				for i in range(0, len(pvalues)):
					result.append((partial and pvalues[i].find(values[i]) >= 0) \
							or (regex and bool(re.match(values[i], pvalues[i]))))

			# we're only interested in full matches in general
			else:
				result = [values[i] in pvalues[i].split() for i in range(0, len(pvalues))]
			
			# some funky logic operations to invert the adjust the match if negations were requested
			result = [(negated[i] and not result[i]) or (not negated[i] and result[i]) for i in range(0, len(result))]
		
			# more logic stuff for conjunction or disjunction
			if (operator == "or" and True in result) or (operator == "and" and not False in result):
				if debug > 0:
					sys.stderr.write("Match found: %s\n" % pv)
				if debug > 1:
					for i in range(0, len(keys_uniq)):
						sys.stderr.write("%s from %s: %s\n" % (keys_uniq[i], pv, pvalues_orig[i]))
				if verbose:
					resultlist.append(pv)
				else:
					if not p in resultlist:
						resultlist.append(p)
	return resultlist
