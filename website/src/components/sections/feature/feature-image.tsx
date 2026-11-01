export const FeatureImage = ({
  src,
  label,
  className = '',
}: {
  src: string;
  label: string;
  className?: string;
}) => {
  return (
    <div className='relative overflow-hidden rounded-(--radius) shadow-2xl'>
      <picture>
        <img
          src={src}
          alt={label}
          aria-label={label}
          loading='lazy'
          className={`size-full object-cover ${className}`}
          style={{
            maxWidth: '100%',
          }}
          onLoad={(e) => {
            const img = e.target as HTMLImageElement;
            if (img.naturalWidth > 0) {
              img.style.width = '100%';
            }
          }}
        />
      </picture>
    </div>
  );
};
