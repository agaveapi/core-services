for i in `find $(pwd) -name "org.eclipse.wst.common.project.facet.core.xml"`; do
	sed -i 's/1\.6/1\.7/g' $i 
done

