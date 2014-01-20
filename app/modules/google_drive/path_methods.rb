module GoogleDrive
  class Session
    def collection_by_path(pathname)
      names = pathname.split('/')
      current = self.collection_by_title(names[0])
      names[1..-1].each do |name|
        current = current.subcollection_by_title(name)
      end
      current
    end
  end
end